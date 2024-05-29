defmodule MobileFoodWeb.Api.PermitsTest do
  use MobileFoodTest.Web.ConnCase
  import Mox

  defmodule Permit do
    use Ecto.Schema
    @primary_key false

    embedded_schema do
      field :ext_id, :string
      field :number, :string
      field :type, Ecto.Enum, values: [:truck, :push_cart]
      field :name, :string
      field :food, {:array, :string}
      field :latitude, :decimal
      field :longitude, :decimal
      field :address, :string
      field :location_description, :string
    end
  end

  describe "Permits API" do
    test "returns permits list in expected format" do
      stub(MobileFoodWeb.FinchMock, :request, fn _req, _ -> permits_response() end)

      conn = get(build_conn(), "/api/permits")
      assert permits = json_response(conn, 200)

      validation_results = Enum.map(permits, &validate_permit/1)
      assert Enum.reject(validation_results, &(&1 == :ok)) == []
    end

    test "returns error if failed to request a data provider" do
      stub(MobileFoodWeb.FinchMock, :request, fn _req, _ ->
        {:error, %Finch.Error{reason: :disconnected}}
      end)

      conn = get(build_conn(), "/api/permits")
      assert respose = json_response(conn, 502)
      assert respose["error"] == "Failed to get permits from a dara provider"
    end

    test "returns error if received an unexpected reponse status from a data provider" do
      stub(MobileFoodWeb.FinchMock, :request, fn _req, _ ->
        {:ok, %Finch.Response{status: 500, body: nil}}
      end)

      conn = get(build_conn(), "/api/permits")
      assert respose = json_response(conn, 502)
      assert respose["error"] == "Failed to get permits from a dara provider"
    end

    test "returns error if failed to decode response from a data provider" do
      stub(MobileFoodWeb.FinchMock, :request, fn _req, _ ->
        {:ok, %Finch.Response{status: 200, body: "Test"}}
      end)

      conn = get(build_conn(), "/api/permits")
      assert respose = json_response(conn, 502)
      assert respose["error"] == "Failed to get permits from a dara provider"
    end

    test "filters out permints entries returned by a data provider is they don't pass validation" do
      stub(MobileFoodWeb.FinchMock, :request, fn _req, _ -> reponse_with_invalid_permits() end)

      conn = get(build_conn(), "/api/permits")
      assert permits = json_response(conn, 200)

      assert permits == []
    end

    test "logs error if failed to request a data provider" do
      stub(MobileFoodWeb.FinchMock, :request, fn _req, _ ->
        {:error, %Finch.Error{reason: :disconnected}}
      end)

      logs = ExUnit.CaptureLog.capture_log(fn -> get(build_conn(), "/api/permits") end)

      assert logs =~ "Failed to request a permits provider"
    end

    test "logs error if received an unexpected reponse status from a data provider" do
      stub(MobileFoodWeb.FinchMock, :request, fn _req, _ ->
        {:ok, %Finch.Response{status: 500, body: nil}}
      end)

      logs = ExUnit.CaptureLog.capture_log(fn -> get(build_conn(), "/api/permits") end)

      assert logs =~ "Unexpected status returned by a permits provider"
    end

    test "logs error if failed to decode response from a data provider" do
      stub(MobileFoodWeb.FinchMock, :request, fn _req, _ ->
        {:ok, %Finch.Response{status: 200, body: "Test"}}
      end)

      logs = ExUnit.CaptureLog.capture_log(fn -> get(build_conn(), "/api/permits") end)

      assert logs =~ "Failed to decode data returned by permits provider"
    end

    test "logs permints entries returned by a data provider that don't pass validation" do
      stub(MobileFoodWeb.FinchMock, :request, fn _req, _ -> reponse_with_invalid_permits() end)

      logs = ExUnit.CaptureLog.capture_log(fn -> get(build_conn(), "/api/permits") end)

      assert logs =~ "Errors occured during permits processing"
    end
  end

  defp validate_permit(permit) do
    permitted = ~w/ext_id number type name food latitude longitude address location_description/a

    %Permit{}
    |> Ecto.Changeset.cast(permit, permitted)
    |> Ecto.Changeset.validate_required(~w/ext_id number name address/a)
    |> case do
      %{valid?: true} ->
        :ok

      %{errors: errors} ->
        {:error, errors}
    end
  end

  defp reponse_with_invalid_permits() do
    content =
      Jason.encode!([
        %{"facilitytype" => "Truck"},
        %{"objectid" => nil, "facilitytype" => "Truck"},
        %{}
      ])

    {:ok, %Finch.Response{status: 200, headers: [], body: content}}
  end

  defp permits_response() do
    content = File.read!("test/support/mobile_food_test/permits_data.json")
    {:ok, %Finch.Response{status: 200, headers: [], body: content}}
  end
end

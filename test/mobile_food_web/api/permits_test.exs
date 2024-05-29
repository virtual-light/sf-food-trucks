defmodule MobileFoodWeb.Api.PermitsTest do
  use MobileFoodTest.Web.ConnCase

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
      conn = get(build_conn(), "/api/permits")
      assert permits = json_response(conn, 200)

      validation_results = Enum.map(permits, &validate_permit/1)
      assert Enum.reject(validation_results, &(&1 == :ok)) == []
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
end

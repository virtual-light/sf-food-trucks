defmodule MobileFood do
  @moduledoc """
  MobileFood keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  require Logger
  alias MobileFood.Errors
  alias MobileFood.Permit

  @permits_uri "https://data.sfgov.org/resource/rqzj-sfat.json"

  # TODO: Replace to "unlimited" for data version 2.1: https://dev.socrata.com/docs/paging
  @max_limit 50_000

  @type permit :: %{
          ext_id: :string,
          number: :string,
          type: :truck | :push_cart | nil,
          name: :string,
          food: list(:string),
          latitude: :decimal,
          longitude: :decimal,
          address: :string,
          location_description: :string | nil
        }

  @spec permits :: [permit()]
  def permits do
    with {:ok, %{status: 200, body: body}} <- fetch_permits_params() do
      body
      |> Jason.decode!()
      |> build_permits()
    end
  end

  defp build_permits(permits_params) do
    {processed_permits, collected_errors} =
      Enum.reduce(permits_params, {[], Errors.new()}, fn params, {permits, errors} ->
        case build_permit(params) do
          {:ok, permit} ->
            # Assuming no duplications in data provided by API
            {[format_permit(permit) | permits], errors}

          {:error, changeset} ->
            {permits, Errors.append(errors, params["objectid"], changeset)}
        end
      end)

    unless Errors.empty?(collected_errors) do
      Logger.warning("Errors occured during permits processing", Errors.dump(collected_errors))
    end

    processed_permits
  end

  defp build_permit(permit_params) do
    %Permit{}
    |> Ecto.Changeset.cast(
      permit_params,
      ~w/objectid permit facilitytype applicant fooditems latitude longitude address locationdescription/a
    )
    |> Ecto.Changeset.validate_required(~w/objectid permit applicant latitude longitude address/a)
    |> Ecto.Changeset.validate_inclusion(:facilitytype, ["Truck", "Push Cart"])
    |> check_and_apply_changes()
  end

  # NOTE: Can be entirely replaced by https://hexdocs.pm/socrata (?)
  defp fetch_permits_params do
    :get
    |> Finch.build(permits_uri())
    |> finch_client().request(MobileFoodFinch)
  end

  defp permits_uri do
    query = %{status: "APPROVED", "$limit": @max_limit}
    URI.to_string(%{URI.new!(@permits_uri) | query: URI.encode_query(query)})
  end

  defp check_and_apply_changes(changeset) do
    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end

  defp format_permit(permit_data) do
    %{
      ext_id: permit_data.objectid,
      number: permit_data.permit,
      type: format_type(permit_data.facilitytype),
      name: permit_data.applicant,
      food: String.split(permit_data.fooditems, ~r/\s*\:+\s*/, trim: true),
      location_description: permit_data.locationdescription,
      latitude: permit_data.latitude,
      longitude: permit_data.longitude,
      address: permit_data.address
    }
  end

  defp format_type(external_type) do
    with type when type != nil <- external_type do
      if type == "Truck", do: :truck, else: :push_cart
    end
  end

  defp finch_client do
    :mobile_food
    |> Application.fetch_env!(:finch)
    |> Keyword.fetch!(:client)
  end
end

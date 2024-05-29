defmodule MobileFood.Permit do
  @moduledoc """
  Representation of permits data returned by https://data.sfgov.org/resource/rqzj-sfat.json
  More info: https://data.sfgov.org/Economy-and-Community/Mobile-Food-Facility-Permit/rqzj-sfat/about_data
  """

  use Ecto.Schema
  @primary_key false

  embedded_schema do
    # NOTE: `objectid` represented as a string because only used as an identifier.
    # Can be represented as decimal if needed because it's only source specifies it as [Number](https://dev.socrata.com/docs/datatypes/number.html)
    field :objectid, :string

    field :permit, :string
    field :facilitytype, :string
    field :applicant, :string
    field :fooditems, :string
    field :latitude, :decimal
    field :longitude, :decimal
    field :address, :string
    field :locationdescription, :string
  end

  @type t :: %__MODULE__{}
end

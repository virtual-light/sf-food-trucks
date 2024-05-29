defmodule MobileFood.Errors do
  @moduledoc """
  Data structure used to collect errors in a way
  to make it easy to batch errors details and their identifiers.
  """

  defstruct errors_data: [], objects_ids: MapSet.new()

  @type t :: %__MODULE__{}

  @spec new() :: t()
  def new, do: %__MODULE__{}

  @spec empty?(t) :: boolean()
  def empty?(errors), do: Enum.empty?(errors.errors_data)

  @spec append(t, String.t() | nil, Ecto.Changeset.t()) :: t
  def append(errors, object_id, changeset) do
    error_data = %{object_id: object_id, details: get_changeset_error(changeset)}
    new_errors = %{errors | errors_data: [error_data | errors.errors_data]}

    if is_nil(object_id) do
      new_errors
    else
      %{new_errors | objects_ids: MapSet.put(errors.objects_ids, object_id)}
    end
  end

  @spec dump(t) :: [objects_ids: String.t(), errors_data: String.t()]
  def dump(errors) do
    [
      objects_ids: Jason.encode!(Enum.to_list(errors.objects_ids)),
      errors_data: Jason.encode!(errors.errors_data)
    ]
  end

  defp get_changeset_error(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts
        |> Keyword.get(String.to_existing_atom(key), key)
        |> to_string()
      end)
    end)
  end
end

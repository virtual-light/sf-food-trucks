defmodule MobileFoodWeb.PermitController do
  use Phoenix.Controller

  def index(conn, _params) do
    case MobileFood.permits() do
      {:ok, permits} ->
        json(conn, permits)

      :error ->
        conn
        |> Plug.Conn.put_status(502)
        |> json(%{error: "Failed to get permits from a dara provider"})
    end
  end
end

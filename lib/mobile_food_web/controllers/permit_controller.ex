defmodule MobileFoodWeb.PermitController do
  use Phoenix.Controller

  def index(conn, _params) do
    json(conn, MobileFood.permits())
  end
end

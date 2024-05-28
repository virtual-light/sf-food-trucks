defmodule MobileFood.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: MobileFoodFinch},
      MobileFoodWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:mobile_food, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MobileFood.PubSub},
      # Start a worker by calling: MobileFood.Worker.start_link(arg)
      # {MobileFood.Worker, arg},
      # Start to serve requests, typically the last entry
      MobileFoodWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MobileFood.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MobileFoodWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

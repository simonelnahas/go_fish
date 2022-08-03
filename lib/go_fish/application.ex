defmodule GoFish.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GoFishWeb.Telemetry,
      {Phoenix.PubSub, name: GoFish.PubSub},
      GoFishWeb.Endpoint,
      {GoFish.Ocean, []}, # TODO separate into their own supervisor
      {GoFish.Controller, []},
      Supervisor.child_spec({GoFish.Player, {:john, true}}, id: :john),
      Supervisor.child_spec({GoFish.Player, {:simon, false}}, id: :simon)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: GoFish.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GoFishWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

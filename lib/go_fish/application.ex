defmodule GoFish.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GoFishWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GoFish.PubSub},
      # Start the Endpoint (http/https)
      GoFishWeb.Endpoint,
      # Start a worker by calling: GoFish.Worker.start_link(arg)
      # {GoFish.Worker, arg}
      {GoFish.Ocean, []}, # TODO separate into their own supervisor
      Supervisor.child_spec({GoFish.Player, {:john, true}}, id: :john),
      Supervisor.child_spec({GoFish.Player, {:simon, false}}, id: :simon)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GoFish.Supervisor]
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

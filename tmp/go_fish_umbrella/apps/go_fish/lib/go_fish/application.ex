defmodule GoFish.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: GoFish.PubSub},
      {GoFish.Controller, []},
      {GoFish.Ocean, []},
      Supervisor.child_spec({GoFish.Player, {:john, true}}, id: :john),
      Supervisor.child_spec({GoFish.Player, {:simon, false}}, id: :simon)
    ]

    Supervisor.start_link(children, strategy: :rest_for_one, name: GoFish.Supervisor)
  end
end

defmodule GoFish.GameSupervisor do
  @moduledoc false
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    # players = Application.get_env(__MODULE__, :players) #get the players here and start the application based on that.

    children = [ #TODO: move to supervisor file. from here. Put inside start_link
      {GoFish.Controller, []},
      {GoFish.Ocean, []},
      Supervisor.child_spec({GoFish.Player, {:john, true}}, id: :john),
      Supervisor.child_spec({GoFish.Player, {:simon, false}}, id: :simon)
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end

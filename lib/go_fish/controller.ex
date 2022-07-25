defmodule GoFish.Controller do
  use GenServer
  # API
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def new_player(player_name) do
    GenServer.call(__MODULE__, {:new_player, player_name})
  end

  def query() do
    GenServer.call(__MODULE__, :query)
  end

  def start_game(player_list) do
    GenServer.call(__MODULE__, {:start_game, player_list})
  end

  def game_over() do
    GenServer.call(__MODULE__, :game_over)
  end

  def ocean_empty() do
    GenServer.cast(__MODULE__, :ocean_empty)
  end

  def got_cards() do
    GenServer.cast(__MODULE__, :got_cards)
  end

  def out_of_cards() do
    GenServer.cast(__MODULE__, :out_of_cards)
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end


  #Helper functions

  def name_to_id(name) do
    String.to_atom(name)
  end


  # Callback
  def init(_arg) do
    {:ok, %{:players => [], :game_state => :in_progress, :players_without_cards => 0, :ocean_empty => false}}
  end

  def handle_call({:new_player, player_name}, _from, state) do
    {:reply, {:new_player_added, player_name}, Map.update!(state, :players, fn x -> [player_name|x] end)}
  end

  def handle_call(:query, _from, state) do
    {:reply, {:ok, state}, state}
  end

  def handle_call({:start_game, player_list}, _from, state) do
    GoFish.Ocean.start_link(nil)
    for name <- player_list do
      GoFish.Player.start_link({name, false})
    end
    GoFish.Player.make_turn(hd(player_list))
    {:reply, :new_game, Map.update!(state, :game_state, fn _x -> :in_progress end)}
  end

  def handle_call(:game_over, _from, state) when state.game_state == :in_progress do
    for name <- state.players do
      GoFish.Player.stop(name)
    end
    GoFish.Ocean.stop()
    {:reply, :game_terminated, %{:players => [], :game_state => :game_over, :players_without_cards => 0, :ocean_empty => true}}
  end

  def handle_call(:game_over, _from, state) do
    {:reply, :no_game_in_progress, state}
  end

  def handle_cast(:ocean_empty, state) do
    {:noreply, Map.update!(state, :ocean_empty, fn _x -> true end)}
  end

  def handle_cast(:got_cards, state) do
    {:noreply, Map.update!(state, :players_without_cards, fn x -> x - 1 end)}
  end

  def handle_cast(:out_of_cards, state) when state.players_without_cards == (length(state.players)-1)
  and state.ocean_empty == true
  and state.game_state == :in_progress do
      for name <- state.players do
        GoFish.Player.stop(name)
      end
      GoFish.Ocean.stop()
    {:noreply, %{:players => [], :game_state => :game_over, :players_without_cards => 0, :ocean_empty => true}}
  end

  def handle_cast(:out_of_cards, state) do
    {:noreply, Map.update!(state, :players_without_cards, fn x -> x + 1 end)}
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal}
  end


#TODO      add winner state and get controller to calculate winner when game is over.

end

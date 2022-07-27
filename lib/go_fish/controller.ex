defmodule GoFish.Controller do
  use GenServer
  # API
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def new_player(player_name) do
    GenServer.call(__MODULE__, {:new_player, player_name})
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def start_game(player_list) do
    GenServer.call(__MODULE__, {:start_game, player_list})
  end

  def game_over() do
    GenServer.call(__MODULE__, :game_over)
  end

  def book_made() do
    GenServer.cast(__MODULE__, :book_made)
  end

  def ocean_empty() do
    GenServer.cast(__MODULE__, :ocean_empty)
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end


  #Helper functions

  # def name_to_id(name) do
  #   String.to_atom(name)
  # end

  def get_book_scores(state) do
    Enum.map(state.players, fn x -> {x, length(Map.get(GoFish.Player.get_state(x), :books))} end)
  end

  def most_books([{name1, books1}, {name2, books2}]) do
    if books1 > books2 do
      {name1, books1}
    else
      {name2, books2}
    end
  end

  def most_books(list_of_tuples) do
    most_books([hd(list_of_tuples),most_books(tl(list_of_tuples))])
  end

  def game_over_state(state) do
    %{:players => [], :game_state => :game_over, :total_books => 0, :ocean_empty => true, :winner => most_books(get_book_scores(state))}
  end

  def initial_game_state() do
    %{:players => [], :game_state => :in_progress, :total_books => 0, :ocean_empty => false, :winner => :undetermined}
  end


  # Callback
  def init(_arg) do
    {:ok, initial_game_state()}
  end

  def handle_call({:new_player, player_name}, _from, state) do
    {:reply, {:new_player_added, player_name}, Map.update!(state, :players, fn x -> [player_name|x] end)}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:start_game, player_list}, _from, state) do
    GoFish.Ocean.start_link(nil)
    for name <- player_list do
      GoFish.Player.start_link({name, false})
    end
    GoFish.Player.give_turn_to(hd(player_list))
    {:reply, :new_game, Map.put(state, :game_state, :in_progress)}
  end

  def handle_call(:game_over, _from, state) when state.game_state == :in_progress do
    final_state = game_over_state(state)
    for name <- state.players do
      GoFish.Player.stop(name)
    end
    GoFish.Ocean.stop()
    {:reply, :game_terminated, final_state}
  end

  def handle_call(:game_over, _from, state) do
    {:reply, :no_game_in_progress, state}
  end

  def handle_cast(:book_made, state) when state.total_books == 12 do
    IO.puts("Final book")
    final_state = game_over_state(state)
    for name <- state.players do
      GoFish.Player.stop(name)
    end
    GoFish.Ocean.stop()
    {:noreply, final_state}
  end

  def handle_cast(:book_made, state) do
    IO.puts("Book made")
    {:noreply, Map.update!(state, :total_books, fn x -> x + 1 end)}
  end

  def handle_cast(:ocean_empty, state) do
    {:noreply, Map.put(state, :ocean_empty, true)}
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal}
  end

end

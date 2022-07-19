defmodule GoFish.Player do
  use GenServer


  # Client API

  def start_link(name, isMyTurn) do
    GenServer.start_link(__MODULE__, isMyTurn, name: name)
  end

  def stop(name) do
    GenServer.cast(name, :stop)
  end

  # called on the taker of cards
  def take_all_your(num, taker, giver) do
    GenServer.call(taker, {:take_all_your, num, giver})
  end

  # called on the giver of cards
  def give_all_my(num, giver) do
    GenServer.call(giver, {:give_all_my, num})
  end

  def get_state(name) do
    GenServer.call(name, :get_state)
  end

  def draw_cards(name, num) do
    GenServer.call(name, {:draw_cards, num})
  end


  # Server

  def init(true) do
    {:ok,
      # initial state:
      %{:hand => [], :isMyTurn => true, :books => []}}
  end

  def init(false) do
    {:ok,
      # initial state:
      %{:hand => [], :isMyTurn => false, :books => []}}
      #TODO: starting removing :hand and :books from initial state and then
      # set them when used the first time
  end

  def handle_cast(:stop, _state) do
    {:stop, :normal}
  end

  def get_matches_from_hand(hand, value) do
    case Enum.group_by(hand, fn card -> card.value == value end) do
      %{true => matches, false => new_hand} ->
        %{:matches => matches, :new_hand => new_hand}
      %{false => new_hand}  ->
        %{:matches => [], :new_hand => new_hand}
      %{true => matches}  ->
        %{:matches => matches, :new_hand => []}
      %{} ->
        %{:matches => [], :new_hand => []}
    end
  end

  def get_books(cards) do
    cards
      |> Enum.group_by(& &1.value)
      |> Map.to_list()
      |> Enum.filter(fn {_key, value} -> Enum.count(value) == 4 end)
      |> Enum.map(fn {key, _value} -> key end)
  end

  def create_books(state) do
    %{:hand => hand} = state
    books = get_books(hand)
    if books != [] do
      IO.puts("collected books: #{inspect(books)}")
    end
    state_with_books = %{state | :books => books ++ Map.get(state,:books)}
    List.foldl(books, state_with_books,
      fn book_value, s ->
        %{:new_hand => new_hand} = get_matches_from_hand(Map.get(s, :hand), book_value)
        %{s | :hand => new_hand}
    end)
  end

  def add_card(state, card) do
    %{state | :hand => [card | Map.get(state, :hand)]}
     |> create_books()
  end

  def add_cards(state, cards) do
    List.foldl(cards, state, & add_card(&2, &1))
  end

  def handle_call({:take_all_your, num, giver}, _from, state) do
    # TODO John: refactor out into functions
    IO.puts("taking cards with value #{num} from #{giver}")
    if Map.get(state,:isMyTurn) do
      IO.puts("it is my turn")
      case give_all_my(num, giver) do
        :go_fish ->
          IO.puts("They didn't have the requested value so I go fishing")
          case GoFish.Ocean.take_card() do
              {:card, card} ->
                IO.puts("I drew the card #{inspect(card)} from the ocean")
                {:reply, :went_fishing, %{add_card(state,card) | :isMyTurn => false}}
              :no_cards_left ->
                IO.puts("There are no cards left in the ocean")
                {:reply, :no_cards_left, state} #TODO handle when game is over
            end
        {:matches, matches} ->
          IO.puts("Yay! I got the cards #{inspect(matches)}")
          {:reply, {:got_cards, matches}, %{state | :hand => matches ++ Map.get(state, :hand)}}
      end
    else
      IO.puts("I tried to take cards, but it wasn't my turn")
      {:reply, :not_my_turn, state}
    end
  end

  def get_matches(hand, value, state) do
    case get_matches_from_hand(hand, value) do
      %{:matches => []} ->
        {:reply,
          :go_fish,
          %{state | :isMyTurn => true}}
      %{:matches => matches, :new_hand => new_hand}  ->
        {:reply,
          {:matches, matches},
          %{state | :hand => new_hand}}

    end
  end

  def handle_call({:give_all_my, num}, _from, state) do
    get_matches(Map.get(state, :hand), num, state)
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:draw_cards, num}, _from, state) do
    case GoFish.Ocean.take_card() do
      :no_cards_left -> {:reply, :no_cards_left, state}
      {:card, card1} ->
        cards = List.foldl(Enum.to_list(2..num), [], fn _x, acc ->
            case GoFish.Ocean.take_card() do
              {:card, card} -> [card| acc]
              :no_cards_left -> acc
            end
          end)
          # IO.puts(":got_cards #{inspect([card1|cards])}\n\n")
        {:reply, :got_cards, add_cards(state, [card1|cards]) }
    end
  end

end

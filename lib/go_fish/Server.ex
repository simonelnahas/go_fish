defmodule GoFish.Server do
  use GenServer
  alias GoFish.Deck

  # Client API

  def start_link do
    GenServer.start_link()
  end

  # Server Side

  def init() do
    # TODO
  end

end

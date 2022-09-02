defmodule GoFishWeb.GameLive do
  use GoFishWeb, :live_view

  import GoFishWeb.GameView



  def mount(_params, _, socket) do
    if nil == Process.whereis(GoFish.Controller) do
      redirect(socket, to: "/welcome")
    else
      # check every 0.1s if there is a change then send it
      if connected?(socket), do: Process.send_after(self(), :update, 100)

      player_states = GoFish.Controller.get_player_states()

      {:ok, assign(socket, :player_states, player_states)}
    end
  end


  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1)
    player_states = GoFish.Controller.get_player_states()
    {:noreply, assign(socket, :player_states, player_states)}
  end
end

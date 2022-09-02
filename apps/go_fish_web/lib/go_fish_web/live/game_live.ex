defmodule GoFishWeb.GameLive do
  use GoFishWeb, :live_view

  import GoFishWeb.GameView

  def mount(_params, _, socket) do
    if nil == Process.whereis(GoFish.Controller) do
      {:ok, redirect(socket, to: "/welcome")}
    else
      # check every 0.1s if there is a change then send it
      if connected?(socket), do: Process.send_after(self(), :update, 100)

      {:ok,
       socket
       |> assign(:players, GoFish.Controller.get_players())
       |> assign(:client_player, nil)}
    end
  end

  def mount(_params, _, %{"assigns" => %{"client_player" => client_player}} = socket) do
    if nil == Process.whereis(GoFish.Controller) do
      {:ok, redirect(socket, to: "/welcome")}
    else
      # check every 0.1s if there is a change then send it
      if connected?(socket), do: Process.send_after(self(), :update, 100)


      {:ok,
       socket
       |> assign(:player_state, GoFish.Player.get_state(String.to_atom(client_player)))
       |> assign(:opponents, Map.delete(GoFish.Controller.get_players(), client_player))
       |> assign(:client_player, nil)}
    end
  end

  def mount(_params, _, %{"assigns" => %{"client_player" => player}} = socket) do
    {:ok,
     socket
     |> assign(:player_state, GoFish.Player.get_state(player))}
  end

  def handle_info(:update, %{"assigns" => %{"client_player" => client_player}} = socket) do
    Process.send_after(self(), :update, 1)
    player_state = GoFish.Player.get_state(client_player)
    {:noreply, assign(socket, :player_state, player_state)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1)
    {:noreply, socket}
  end

  #FIXME seems like it is not handling this event properly
  def handle_event("choose_player", %{"value" => client_player}, socket) do
    {:noreply,
    socket
    |> assign(:client_player, client_player)
    |> assign(:player_state, GoFish.Player.get_state(String.to_atom(client_player))
    |> assign(:opponents, Map.delete(GoFish.Controller.get_players(), client_player))
    )
  }
  end

end

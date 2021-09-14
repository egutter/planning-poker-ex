defmodule PlanningPokerWeb.CasinoLive.Index do
  use PlanningPokerWeb, :live_view

  alias Phoenix.PubSub
  alias PlanningPoker.Casino.CasinoService
  alias PlanningPoker.Casino.Casino

  @topic "casino_topic"

  @impl true
  def mount(_params, session, socket) do
    socket = check_user_is_signed_in(session, socket)

    PubSub.subscribe(PlanningPoker.PubSub, @topic)

    casino = CasinoService.find()

    {:ok,
     socket
     |> assign_all_games(casino)
     |> assign_all_players(casino)}
  end

  @impl true
  def handle_event("open_game", %{"game_name" => game_name}, socket) do
    casino = CasinoService.start_game(game_name)

    PubSub.broadcast_from(PlanningPoker.PubSub, self(), @topic, {:games_changed})

    {:noreply,
     socket
     |> assign_all_games(casino)}
  end

  @impl true
  def handle_params(%{"delete" => game_name}, _uri, socket) do
    casino = CasinoService.remove_game(game_name)

    PubSub.broadcast_from(PlanningPoker.PubSub, self(), @topic, {:games_changed})

    {:noreply,
      socket
      |> assign_all_games(casino)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_player}, socket) do
    casino = CasinoService.find()

    {:noreply,
     socket
     |> assign_all_players(casino)}
  end

  @impl true
  def handle_info({:games_changed}, socket) do
    casino = CasinoService.find()

    {:noreply,
     socket
     |> assign_all_games(casino)}
  end

  def topic(), do: @topic

  defp assign_all_games(socket, casino) do
    assign(socket, games: Casino.all_games(casino))
  end

  defp assign_all_players(socket, casino) do
    assign(socket, players: casino.players)
  end
end

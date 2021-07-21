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

    {:ok, assign(socket, games: Casino.all_games(casino), players: casino.players)}
  end

  @impl true
  def handle_event("open_game", %{"game_name" => game_name}, socket) do
    casino = CasinoService.start_game(game_name)

    PubSub.broadcast_from(PlanningPoker.PubSub, self(), @topic, {:new_game})

    {:noreply, assign(socket, games: Casino.all_games(casino))}
  end

  @impl true
  def handle_info({:new_player}, socket) do
    casino = CasinoService.find()
    {:noreply, assign(socket, players: casino.players)}
  end

  @impl true
  def handle_info({:new_game}, socket) do
    casino = CasinoService.find()
    {:noreply, assign(socket, games: Casino.all_games(casino))}
  end

  def topic(), do: @topic
end

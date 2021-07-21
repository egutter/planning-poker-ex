defmodule PlanningPokerWeb.GameLive.Index do
  use PlanningPokerWeb, :live_view

  import Enum, only: [member?: 2]

  alias Phoenix.PubSub
  alias PlanningPoker.Game.Game
  alias PlanningPoker.Game.GameService
  alias PlanningPoker.Casino.CasinoService

  @topic "game_topic"

  @impl true
  def mount(params, session, socket) do
    socket = check_user_is_signed_in(session, socket)

    PubSub.subscribe(PlanningPoker.PubSub, @topic)

    player = socket.assigns.current_user

    game =
      params["game_name"]
      |> CasinoService.find_game()
      |> GameService.find()

    {:ok,
     assign(socket,
       players: game.players,
       game_name: game.name,
       stories: game.stories,
       in_game: member?(game.players, player)
     )}
  end

  @impl true
  def handle_event("join", %{"game_name" => game_name}, socket) do
    player = socket.assigns.current_user

    game =
      game_name
      |> CasinoService.find_game()
      |> GameService.join(player)

    PubSub.broadcast_from(PlanningPoker.PubSub, self(), @topic, {:change_players, game_name})

    {:noreply, assign(socket, players: game.players, in_game: true)}
  end

  @impl true
  def handle_event("add_story", %{"story_name" => story_name}, socket) do
    game_name = socket.assigns.game_name

    game =
      game_name
      |> CasinoService.find_game()
      |> GameService.add_story(story_name)

    PubSub.broadcast_from(PlanningPoker.PubSub, self(), @topic, {:add_story, game_name})

    {:noreply, assign(socket, stories: game.stories)}
  end

  @impl true
  def handle_event("estimate", %{"story" => story}, socket) do
    game_name = socket.assigns.game_name

    PubSub.broadcast_from(
      PlanningPoker.PubSub,
      self(),
      @topic,
      {:estimate_story, %{game_name: game_name, story_name: story}}
    )

    {:noreply,
     redirect(socket,
       to: Routes.live_path(socket, PlanningPokerWeb.GameLive.Estimate, game_name, story)
     )}
  end

  @impl true
  def handle_event("leave", %{}, socket) do
    player = socket.assigns.current_user
    game_name = socket.assigns.game_name

    game =
      game_name
      |> CasinoService.find_game()
      |> GameService.leave(player)

    PubSub.broadcast_from(PlanningPoker.PubSub, self(), @topic, {:change_players, game_name})

    {:noreply, assign(socket, players: game.players, in_game: false)}
  end

  @impl true
  def handle_info({:change_players, game_name}, socket) do
    handle_notification(socket, game_name, fn game -> %{players: game.players} end)
  end

  @impl true
  def handle_info({:add_story, game_name}, socket) do
    handle_notification(socket, game_name, fn game -> %{stories: game.stories} end)
  end

  @impl true
  def handle_info({:estimate_story, %{game_name: game_name, story_name: story}}, socket) do
    when_notification_belongs_to_current_game(socket, game_name, fn
      {:same_game} ->
        {:noreply,
         redirect(socket,
           to: Routes.live_path(socket, PlanningPokerWeb.GameLive.Estimate, game_name, story)
         )}

      {:other_game} ->
        {:noreply, socket}
    end)
  end

  defp handle_notification(socket, game_name, fun) do
    when_notification_belongs_to_current_game(socket, game_name, fn
      {:same_game} ->
        game =
          game_name
          |> CasinoService.find_game()
          |> GameService.find()

        {:noreply, assign(socket, fun.(game))}

      {:other_game} ->
        {:noreply, socket}
    end)
  end

  defp when_notification_belongs_to_current_game(socket, game_name, handle_fun) do
    current_game = socket.assigns.game_name

    case game_name do
      ^current_game ->
        handle_fun.({:same_game})

      _ ->
        handle_fun.({:other_game})
    end
  end
end

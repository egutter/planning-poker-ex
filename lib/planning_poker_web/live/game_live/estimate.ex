defmodule PlanningPokerWeb.GameLive.Estimate do
  use PlanningPokerWeb, :live_view
  alias Phoenix.PubSub
  alias PlanningPoker.Casino.CasinoService
  alias PlanningPoker.Game.Game
  alias PlanningPoker.Game.GameService
  alias PlanningPoker.PlanningSession.Story
  alias PlanningPoker.PlanningSession.Fibonacci
  alias PlanningPoker.PlanningSession.Estimate

  @topic "estimate_topic"

  @impl true
  def mount(params, session, socket) do
    socket = check_user_is_signed_in(session, socket)

    PubSub.subscribe(PlanningPoker.PubSub, @topic)

    player = socket.assigns.current_user

    story_name = params["story_name"]

    game =
      params["game_name"]
      |> CasinoService.find_game()
      |> GameService.find()

    story = Game.find_story(game, story_name)

    {:ok,
     assign(socket,
       players: game.players,
       game_name: game.name,
       story_name: story_name,
       deck: Fibonacci.values(),
       estimates: story.estimates,
       my_estimate: Story.find_estimate_by_player(story, player),
       estimates_completed: Story.estimated_by_all_players?(story, game.players)
     )}
  end

  @impl true
  def handle_event("choose-estimate", %{"card" => card}, socket) do
    game_name = socket.assigns.game_name
    story_name = socket.assigns.story_name
    player = socket.assigns.current_user

    game =
      game_name
      |> CasinoService.find_game()
      |> GameService.add_estimate(story_name, player, card)

    story = Game.find_story(game, story_name)

    PubSub.broadcast_from(
      PlanningPoker.PubSub,
      self(),
      @topic,
      {:estimate_chosen, %{game_name: game_name, story_name: story_name}}
    )

    {:noreply,
     assign(socket,
       estimates: story.estimates,
       my_estimate: Story.find_estimate_by_player(story, player),
       estimates_completed: Story.estimated_by_all_players?(story, game.players)
     )}
  end

  @impl true
  def handle_event("finalize-estimation", %{card: card}, socket) do
    game_name = socket.assigns.game_name
    story_name = socket.assigns.story_name

    game_service =
      game_name
      |> CasinoService.find_game()

    story = game_service |> Game.get() |> Game.find_story(story_name)

    game_service |> Game.story_final_estimate(story, card)

    {:noreply,
     redirect(socket,
       to: Routes.live_path(socket, PlanningPokerWeb.GameLive.Index, game_name)
     )}
  end

  @impl true
  def handle_event("restart", _params, socket) do
    game_name = socket.assigns.game_name
    story_name = socket.assigns.story_name

    game =
      game_name
      |> CasinoService.find_game()
      |> GameService.restart(story_name)

    story = Game.find_story(game, story_name)

    PubSub.broadcast_from(
      PlanningPoker.PubSub,
      self(),
      @topic,
      {:estimate_restart, %{game_name: game_name, story_name: story_name}}
    )

    {:noreply,
     assign(socket,
       estimates: story.estimates,
       my_estimate: %Estimate{},
       estimates_completed: false
     )}
  end

  @impl true
  def handle_info({:estimate_chosen, %{game_name: game_name, story_name: story_name}}, socket) do
    handle_notification(socket, game_name, story_name, fn game_id, story ->
      player = socket.assigns.current_user
      game = GameService.find(game_id)

      %{
        estimates: story.estimates,
        my_estimate: Story.find_estimate_by_player(story, player),
        estimates_completed: Story.estimated_by_all_players?(story, game.players)
      }
    end)
  end

  @impl true
  def handle_info({:estimate_restart, %{game_name: game_name, story_name: story_name}}, socket) do
    handle_notification(socket, game_name, story_name, fn game_id, story ->
      story =
        game_id
        |> GameService.restart(story_name)
        |> Game.find_story(story_name)

      %{estimates: story.estimates, my_estimate: %Estimate{}, estimates_completed: false}
    end)
  end

  def player_estimate(estimates_completed, card) do
    if estimates_completed, do: card, else: "-"
  end

  defp handle_notification(socket, game_name, story_name, fun) do
    when_notification_belongs_to_current_game_and_story(socket, game_name, story_name, fn
      {:same_game_and_story} ->
        game_id =
          game_name
          |> CasinoService.find_game()

        story =
          game_id
          |> GameService.find()
          |> Game.find_story(story_name)

        {:noreply, assign(socket, fun.(game_id, story))}

      _ ->
        {:noreply, socket}
    end)
  end

  defp when_notification_belongs_to_current_game_and_story(
         socket,
         game_name,
         story_name,
         handle_fun
       ) do
    current_story = socket.assigns.story_name

    when_notification_belongs_to_current_game(socket, game_name, fn
      {:same_game} ->
        case story_name do
          ^current_story ->
            handle_fun.({:same_game_and_story})

          _ ->
            handle_fun.({:other_story})
        end

      {:other_game} ->
        handle_fun.({:other_game})
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

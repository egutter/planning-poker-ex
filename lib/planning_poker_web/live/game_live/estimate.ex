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
  def mount(%{"story_name" => story_name, "game_name" => game_name}, session, socket) do
    socket = check_user_is_signed_in(session, socket)

    PubSub.subscribe(PlanningPoker.PubSub, @topic)

    game =
      game_name
      |> CasinoService.find_game()
      |> GameService.find()

    story = Game.find_story(game, story_name)

    {:ok,
     socket
     |> assign_game_players(game)
     |> assign_game_name(game)
     |> assign_story_name(story_name)
     |> assign_deck_values()
     |> assign_story_estimates(story)
     |> assign_my_estimate(story)
     |> assign_estimates_completed_and_notify_client(story, game)}
  end

  @impl true
  def handle_event(
        "choose-estimate",
        %{"card" => card},
        %{assigns: %{game_name: game_name, story_name: story_name, current_user: player}} = socket
      ) do
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
     socket
     |> assign_story_estimates(story)
     |> assign_my_estimate(story)
     |> assign_estimates_completed_and_notify_client(story, game)}
  end

  @impl true

  def handle_event("finalize-estimation", %{"card" => card}, socket) do
    game_name = socket.assigns.game_name
    story_name = socket.assigns.story_name

    game_name
    |> CasinoService.find_game()
    |> GameService.close_estimate(story_name, card)

    PubSub.broadcast_from(
      PlanningPoker.PubSub,
      self(),
      @topic,
      {:estimatation_finalized, %{game_name: game_name, story_name: story_name}}
    )

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
     socket
     |> assign_story_estimates(story)
     |> assign_clear_my_estimate()
     |> assign_clear_estimates_completed()}
  end

  @impl true
  def handle_info({:estimate_chosen, %{game_name: game_name, story_name: story_name}}, socket) do
    handle_notification(socket, game_name, story_name, fn game_id, story ->
      player = socket.assigns.current_user
      game = GameService.find(game_id)

      {:noreply,
       socket
       |> assign(estimates: story.estimates)
       |> assign(my_estimate: Story.find_estimate_by_player(story, player))
       |> assign_estimates_completed_and_notify_client(story, game)}
    end)
  end

  def handle_info(
        {:estimatation_finalized, %{game_name: game_name, story_name: story_name}},
        socket
      ) do
    handle_notification(socket, game_name, story_name, fn _game_id, _story ->
      {:noreply,
       redirect(socket,
         to: Routes.live_path(socket, PlanningPokerWeb.GameLive.Index, game_name)
       )}
    end)
  end

  @impl true
  def handle_info({:estimate_restart, %{game_name: game_name, story_name: story_name}}, socket) do
    handle_notification(socket, game_name, story_name, fn game_id, _story ->
      story =
        game_id
        |> GameService.restart(story_name)
        |> Game.find_story(story_name)

      {:noreply,
       socket
       |> assign(estimates: story.estimates)
       |> assign(my_estimate: %Estimate{})
       |> assign(estimates_completed: false)}
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

        fun.(game_id, story)

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

  defp assign_game_players(socket, game) do
    assign(socket, players: game.players)
  end

  defp assign_game_name(socket, game) do
    assign(socket, game_name: game.name)
  end

  defp assign_story_name(socket, story_name) do
    assign(socket, story_name: story_name)
  end

  defp assign_deck_values(socket) do
    assign(socket, deck: Fibonacci.values())
  end

  defp assign_story_estimates(socket, story) do
    assign(socket, estimates: story.estimates)
  end

  defp assign_my_estimate(%{assigns: %{current_user: player}} = socket, story) do
    assign(socket, my_estimate: Story.find_estimate_by_player(story, player))
  end

  defp assign_estimates_completed_and_notify_client(socket, story, game) do
    estimates_completed = Story.estimated_by_all_players?(story, game.players)

    socket
    |> assign(estimates_completed: estimates_completed)
    |> push_event("estimates_completed", %{estimates_completed: estimates_completed})
  end

  defp assign_clear_my_estimate(socket) do
    assign(socket, my_estimate: %Estimate{})
  end

  defp assign_clear_estimates_completed(socket) do
    assign(socket, estimates_completed: false)
  end
end

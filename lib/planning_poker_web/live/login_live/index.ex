defmodule PlanningPokerWeb.LoginLive.Index do
  use PlanningPokerWeb, :live_view

  alias Phoenix.PubSub
  alias PlanningPoker.Casino.CasinoService
  alias PlanningPoker.PlanningSession.Player

  @topic PlanningPokerWeb.CasinoLive.Index.topic()

  @impl true
  def mount(_params, session, socket) do
    socket = check_user_is_not_signed_in(session, socket)
    {:ok, assign(socket, player: Player.new(), trigger_submit: false)}
  end

  @impl true
  def handle_event("validate", %{"player" => player_params}, socket) do
    changeset =
      %Player{}
      |> Player.changeset(player_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, player: changeset)}
  end

  @impl true
  def handle_event("save", %{"player" => player_params}, socket) do
    player = Player.from_map(player_params)

    case CasinoService.join_player(player) do
      {:ok, _casino} ->
        PubSub.broadcast_from(PlanningPoker.PubSub, self(), @topic, {:new_player})
        {:noreply, assign(socket, trigger_submit: true)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

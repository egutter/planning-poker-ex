defmodule PlanningPokerWeb.LiveHelpers do
  import Phoenix.LiveView
  alias PlanningPokerWeb.Router.Helpers, as: Routes
  alias PlanningPoker.PlanningSession.Player
  alias PlanningPoker.Casino.CasinoService

  def check_user_is_signed_in(session, socket) do
    case valid_and_joined?(session) do
      {:ok, player} ->
        assign_new(socket, :current_user, fn -> player end)

      {:invalid, _player} ->
        socket
        |> put_flash(:error, "You must log in to access this page.")
        |> redirect(to: Routes.live_path(socket, PlanningPokerWeb.LoginLive.Index))
    end
  end

  def check_user_is_not_signed_in(session, socket) do
    case valid_and_joined?(session) do
      {:ok, _player} ->
        socket
        |> put_flash(:error, "You are already logged")
        |> redirect(to: Routes.live_path(socket, PlanningPokerWeb.CasinoLive.Index))

      {:invalid, _player} ->
        socket
    end
  end

  def gravatar_url(player) do
    "https://www.gravatar.com/avatar/#{Player.gravatar_url(player)}?s=150&d=identicon"
  end

  defp valid_and_joined?(session) do
    player = Player.from_map(session["current_user"])

    if Player.valid?(player) && CasinoService.joined?(player),
      do: {:ok, player},
      else: {:invalid, player}
  end
end

defmodule PlanningPokerWeb.UserController do
  use PlanningPokerWeb, :controller
  alias PlanningPoker.PlanningSession.Player
  alias PlanningPoker.Casino.CasinoService

  def create(conn, %{"player" => player}) do
    conn
    |> put_session(:current_user, player)
    |> put_flash(:info, "Welcome to our virtual casino")
    |> redirect(to: "/")
    |> halt()
  end

  def destroy(conn, _params) do
    player = Player.from_map(get_session(conn, "current_user"))
    CasinoService.leave_player(player)

    conn
    |> put_session(:current_user, nil)
    |> put_flash(:info, "See you soon big baboon")
    |> redirect(to: "/login")
    |> halt()
  end

end

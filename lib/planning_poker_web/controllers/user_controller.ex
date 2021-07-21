defmodule PlanningPokerWeb.UserController do
  use PlanningPokerWeb, :controller

  def create(conn, %{"player" => player}) do
    conn
    |> put_session(:current_user, player)
    |> put_flash(:info, "Welcome to our virtual casino")
    |> redirect(to: "/")
    |> halt()
  end
end

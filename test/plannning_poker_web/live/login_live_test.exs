defmodule PlanningPokerWeb.LoginLiveTest do
  use PlanningPokerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/login")
    assert disconnected_html =~ "Welcome to the Planning Poker"
    assert render(page_live) =~ "Welcome to the Planning Poker"
  end
end

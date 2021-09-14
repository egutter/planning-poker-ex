defmodule PlanningPokerWeb.CasinoLiveTest do
  use PlanningPokerWeb.ConnCase
  use ExMatchers

  alias PlanningPoker.Casino.Casino
  alias PlanningPoker.Casino.CasinoService
  alias PlanningPoker.PlanningSession.Player

  import Phoenix.LiveViewTest

  setup do
    Application.stop(:planning_poker)
    :ok = Application.start(:planning_poker)
  end

  setup %{conn: conn} do
    player_data = %{"name" => "John", "email" => "Doe"}

    player = Player.from_map(player_data)
    {:ok, _casino} = CasinoService.join_player(player)

    conn =
      conn
      |> Plug.Test.init_test_session(current_user: player_data)

    {:ok, %{conn: conn, player: player}}
  end

  test "render the title and player welcome", %{conn: conn, player: player} do
    {:ok, _view, html} = live(conn, "/")

    expect(html, to: include("Have fun and enjoy poker!"))
    expect(html, to: include("Hello, #{player.name}"))
  end

  test "add a new game", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    game_name = "A new game"

    rendered_submit =
      view
      |> element("#game-form")
      |> render_submit(%{game_name: game_name})

    new_game = CasinoService.find() |> Casino.find_game(game_name)

    expect(rendered_submit, to: include(game_name))
    expect(new_game, to_not: eq(nil))
  end
end

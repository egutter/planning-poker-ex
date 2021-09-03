defmodule PlanningPoker.Casino.CasinoServiceTest do
  use ExUnit.Case
  use ExMatchers

  alias PlanningPoker.Casino.Casino
  alias PlanningPoker.Casino.CasinoService
  alias PlanningPoker.Game.GameService
  alias PlanningPoker.PlanningSession.Player

  @game_name "test game"

  setup do
    Application.stop(:planning_poker)
    :ok = Application.start(:planning_poker)
  end

  test "casino has no games" do
    casino = CasinoService.find()

    expect(casino.games, to: be_empty())
  end

  test "casino has games" do
    game =
      @game_name
      |> CasinoService.start_game()
      |> Casino.find_game(@game_name)
      |> GameService.find()

    expect(game.name, to: eq(@game_name))
  end

  test "a valid player joins the casino" do
    player = %Player{name: 'John', email: 'john@doe.com'}

    {:ok, casino} = CasinoService.join_player(player)

    expect(Casino.joined?(casino, player), to: eq(true))
  end

  test "an invalid player cannot join the casino" do
    player = %Player{name: 'John'}

    {:error, _changeset} = CasinoService.join_player(player)

    expect(CasinoService.joined?(player), to: eq(false))
  end
end

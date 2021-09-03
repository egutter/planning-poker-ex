defmodule PlanningPoker.Casino.CasinoTest do
  use ExUnit.Case, async: true
  use ExMatchers

  alias PlanningPoker.Casino.Casino
  alias PlanningPoker.Game.GameService
  alias PlanningPoker.PlanningSession.Player

  @game_name "test game"

  describe "a new casino is empty" do
    test "casino has no games" do
      casino = %Casino{}

      expect(Casino.all_games(casino), to: be_empty())
    end

    test "casino has no players" do
      casino = %Casino{}

      expect(casino.players, to: be_empty())
    end
  end

  describe "Casino with games" do
    test "starts a new game" do
      casino = Casino.start_game(%Casino{}, @game_name)

      expect(casino.games, to_not: be_empty())
    end

    test "all games" do
      casino = Casino.start_game(%Casino{}, @game_name)

      expect(Casino.all_games(casino), to_not: be_empty())
    end

    test "finds a game by name" do
      game =
        %Casino{}
        |> Casino.start_game(@game_name)
        |> Casino.find_game(@game_name)
        |> GameService.find()

      expect(game.name, to: eq(@game_name))
    end
  end

  describe "Casino has players" do
    setup do
      [player: %Player{name: "John", email: "john@doe.com"}]
    end

    test "adds a player", context do
      casino =
        %Casino{}
        |> Casino.add_player(context[:player])

      expect(casino.players, to_not: be_empty())
    end

    test "player joined?", context do
      casino =
        %Casino{}
        |> Casino.add_player(context[:player])

      joined = Casino.joined?(casino, context[:player])

      expect(joined, to: eq(true))
    end
  end
end

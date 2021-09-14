defmodule PlanningPoker.Casino.Casino do
  alias PlanningPoker.Game.GameService
  import Map, only: [values: 1]
  import Enum, only: [map: 2, sort: 1, member?: 2]

  defstruct players: MapSet.new(), games: %{}

  def all_games(casino) do
    casino.games
    |> values()
    |> sort()
    |> map(&GameService.find(&1))
  end

  def start_game(casino, game_name) do
    {:ok, game_id} = GameService.new(game_name)
    games = Map.put(casino.games, game_name, game_id)
    %{casino | games: games}
  end

  def remove_game(casino, game_name) do
    casino
    |> find_game(game_name)
    |> GameService.delete()

    games = Map.delete(casino.games, game_name)
    %{casino | games: games}
  end

  def find_game(casino, game_name) do
    casino.games[game_name]
  end

  def add_player(casino, player) do
    %{casino | players: MapSet.put(casino.players, player)}
  end

  def joined?(casino, player) do
    casino.players |> member?(player)
  end
end

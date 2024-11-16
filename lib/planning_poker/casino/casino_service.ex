defmodule PlanningPoker.Casino.CasinoService do
  alias PlanningPoker.Casino.Casino
  alias PlanningPoker.Casino.CasinoRepo
  alias PlanningPoker.PlanningSession.Player

  def find() do
    CasinoRepo.find()
  end

  def start_game(game_name) do
    CasinoRepo.save(fn casino ->
      casino = Casino.start_game(casino, game_name)
      {casino, casino}
    end)
  end

  def remove_game(game_name) do
    CasinoRepo.save(fn casino ->
      casino = Casino.remove_game(casino, game_name)
      {casino, casino}
    end)
  end

  def find_game(game_name) do
    CasinoRepo.find() |> Casino.find_game(game_name)
  end

  def join_player(player) do
    case Player.changeset(player) do
      %Ecto.Changeset{valid?: true} ->
        casino = CasinoRepo.find() |> Casino.add_player(player)
        {:ok, CasinoRepo.save(casino)}

      changeset ->
        {:error, changeset}
    end
  end

  def leave_player(player) do
    CasinoRepo.save(fn casino ->
      casino = Casino.remove_player(casino, player)
      {casino, casino}
    end)
  end

  def joined?(player) do
    CasinoRepo.find() |> Casino.joined?(player)
  end
end

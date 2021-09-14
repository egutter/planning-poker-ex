defmodule PlanningPoker.Game.GameService do
  alias PlanningPoker.Game.GameRepo
  alias PlanningPoker.Game.Game
  alias PlanningPoker.PlanningSession.Story
  alias PlanningPoker.PlanningSession.Estimate

  def new(name) do
    game = Game.new(name)
    GameRepo.create(game)
  end

  def find(id) do
    GameRepo.find(id)
  end

  def delete(id) do
    GameRepo.delete(id)
  end

  def join(id, player) do
    game = GameRepo.find(id) |> Game.join(player)
    GameRepo.save(id, game)
  end

  def leave(id, player) do
    game = GameRepo.find(id) |> Game.leave(player)
    GameRepo.save(id, game)
  end

  def add_story(id, story_name) do
    game = GameRepo.find(id) |> Game.add_story(Story.new(story_name))
    GameRepo.save(id, game)
  end

  def add_estimate(id, story_name, player, card) do
    new_estimate = Estimate.new(player, card)
    game = GameRepo.find(id) |> Game.add_estimate(story_name, new_estimate)
    GameRepo.save(id, game)
  end

  def close_estimate(id, story_name, card) do
    game = GameRepo.find(id) |> Game.close_estimate(story_name, card)
    GameRepo.save(id, game)
  end

  def find_story(id, story_name) do
    GameRepo.find(id) |> Game.find_story(story_name)
  end

  def restart(id, story_name) do
    game = GameRepo.find(id) |> Game.restart(story_name)
    GameRepo.save(id, game)
  end
end

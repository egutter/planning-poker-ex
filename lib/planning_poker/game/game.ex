defmodule PlanningPoker.Game.Game do
  alias PlanningPoker.Game.Game
  alias PlanningPoker.PlanningSession.Story

  defstruct name: "", players: [], stories: []

  def new(name) do
    %Game{name: name}
  end

  def join(game, player) do
    %{game | players: [player | game.players]}
  end

  def leave(game, player) do
    %{game | players: Enum.reject(game.players, &(&1 == player))}
  end

  def add_story(game, story) do
    %{game | stories: [story | game.stories]}
  end

  def add_estimate(game, story_name, new_estimate) do
    story =
      game
      |> find_story(story_name)
      |> Story.add_estimate(new_estimate)

    %{game | stories: update_story(game, story)}
  end

  def close_estimate(game, story_name, card) do
    story =
      game
      |> find_story(story_name)
      |> Story.close_estimate(card)

    %{game | stories: update_story(game, story)}
  end

  def restart(game, story_name) do
    story =
      game
      |> find_story(story_name)
      |> Story.reset_estimates()

    %{game | stories: update_story(game, story)}
  end

  def find_story(game, story_name) do
    game.stories
    |> Enum.find(fn story -> Story.has_name?(story, story_name) end)
  end

  def stories_to_estimate(game) do
    Enum.reject(game.stories, &(Story.estimated?(&1)))
  end

  def estimated_stories(game) do
    Enum.filter(game.stories, &(Story.estimated?(&1)))
  end

  defp update_story(game, story) do
    story_name = story.name

    game.stories
    |> Enum.map(fn
      %Story{name: ^story_name} -> story
      other -> other
    end)
  end
end

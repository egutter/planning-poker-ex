defmodule PlanningPoker.PlanningSession.Story do
  alias PlanningPoker.PlanningSession.Story
  alias PlanningPoker.PlanningSession.Estimate
  import Enum, only: [count: 1]

  defstruct name: "", estimates: [], final_estimate: ""

  def new(story_name) do
    %Story{name: story_name}
  end

  def has_name?(story, story_name), do: story.name == story_name

  def add_estimate(story, new_estimate) do
    case find_estimate_by_player(story, new_estimate.player) do
      %Estimate{filled: false} ->
        %Story{story | estimates: [new_estimate | story.estimates]}

      %Estimate{filled: true} ->
        %Story{story | estimates: update_estimate(story, new_estimate)}
    end
  end

  def reset_estimates(story) do
    %Story{story | estimates: [], final_estimate: ""}
  end

  def close_estimate(story, card) do
    %Story{story | final_estimate: card}
  end

  def find_estimate_by_player(story, player) do
    Enum.find(story.estimates, %Estimate{}, fn estimate -> estimate.player == player end)
  end

  def estimated_by_all_players?(story, players) do
    count(story.estimates) == count(players)
  end

  def estimated?(story) do
    story.final_estimate != ""
  end

  defp update_estimate(story, new_estimate) do
    player = new_estimate.player

    story.estimates
    |> Enum.map(fn
      %Estimate{player: ^player} -> new_estimate
      other -> other
    end)
  end
end

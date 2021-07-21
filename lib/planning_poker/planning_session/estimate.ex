defmodule PlanningPoker.PlanningSession.Estimate do
  alias PlanningPoker.PlanningSession.Estimate

  defstruct player: nil, card: "", filled: false

  def new(player, card) do
    %Estimate{player: player, card: card, filled: true}
  end
end

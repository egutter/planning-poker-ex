defmodule PlanningPoker.Casino.CasinoRepo do
  use Agent
  alias PlanningPoker.Casino.Casino

  @name __MODULE__

  def start_link(_opts) do
    Agent.start_link(fn -> %Casino{} end, name: @name)
  end

  def find() do
    Agent.get(@name, & &1)
  end

  def save(%Casino{} = new_casino) do
    Agent.get_and_update(@name, fn _casino -> {new_casino, new_casino} end)
  end

  def save(fun) when is_function(fun, 1) do
    Agent.get_and_update(@name, fn casino -> fun.(casino) end)
  end
end

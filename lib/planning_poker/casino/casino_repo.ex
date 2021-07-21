defmodule PlanningPoker.Casino.CasinoRepo do
  use Agent
  alias PlanningPoker.Casino.Casino

  def start_link(_opts) do
    Agent.start_link(fn -> %Casino{} end, name: __MODULE__)
  end

  def find() do
    Agent.get(__MODULE__, & &1)
  end

  def save(%Casino{} = new_casino) do
    Agent.get_and_update(__MODULE__, fn _casino -> {new_casino, new_casino} end)
  end

  def save(fun) when is_function(fun, 1) do
    Agent.get_and_update(__MODULE__, fn casino -> fun.(casino) end)
  end
end

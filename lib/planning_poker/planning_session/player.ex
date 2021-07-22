defmodule PlanningPoker.PlanningSession.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlanningPoker.PlanningSession.Player

  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

  embedded_schema do
    field(:name, :string)
    field(:email, :string)
  end

  def new() do
    Player.changeset(%Player{}, %{})
  end

  def valid?(player) do
    changeset(player).valid?
  end

  def from_map(nil), do: %Player{}

  def from_map(%{"name" => name, "email" => email}), do: %Player{name: name, email: email}

  def gravatar_url(player) do
    player.email
    |> String.trim()
    |> String.downcase()
    |> :erlang.md5()
    |> Base.encode16(case: :lower)
  end

  @doc false
  def changeset(player, attrs \\ %{})

  @doc false
  def changeset(player, nil), do: player

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, @mail_regex, message: "invalid email format")
  end
end

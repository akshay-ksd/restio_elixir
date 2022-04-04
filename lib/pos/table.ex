defmodule Pos.Table do
  use Ecto.Schema
  import Ecto.Changeset

  schema "table" do
    field :name, :string
    field :restaurentId, :string

    timestamps()
  end

  def addTableDetails(restaurentId,name) do
    %Pos.Table{restaurentId: restaurentId,
               name: name}
    |> Pos.Repo.insert()
  end

  @doc false
  def changeset(table, attrs) do
    table
    |> cast(attrs, [:restaurentId, :name])
    |> validate_required([:restaurentId, :name])
  end
end

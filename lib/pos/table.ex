defmodule Pos.Table do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Table

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

  def getTableDetailsByRestaurentId(restaurentId) do
    from(p in Table, where: p.restaurentId == ^restaurentId,
    select: %{name: p.name,id: p.id})
    |> Pos.Repo.all()
  end

  @doc false
  def changeset(table, attrs) do
    table
    |> cast(attrs, [:restaurentId, :name])
    |> validate_required([:restaurentId, :name])
  end
end

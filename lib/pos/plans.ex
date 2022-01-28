defmodule Pos.Plans do
  use Ecto.Schema
  alias Pos.Plans
  import Ecto.Changeset

  schema "plans" do
    field :days, :integer
    field :name, :string
    field :plan_id, :string
    field :price, :integer

    timestamps()
  end

  def addPlan(days,name,plan_id,price) do
    %Pos.Plans{days: days,
      name: name,
      plan_id: plan_id,
      price: price}

    |> Pos.Repo.insert()
  end

  def getPlanDetails() do
    Pos.Repo.all(Plans)
  end

  def getPlanById(plan_id) do
    Pos.Repo.get_by(Plans, plan_id: plan_id)
  end

  @doc false
  def changeset(plans, attrs) do
    plans
    |> cast(attrs, [:plan_id, :name, :days, :price])
    |> validate_required([:plan_id, :name, :days, :price])
  end
end

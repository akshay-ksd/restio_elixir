defmodule Pos.RechargeDetails do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.RechargeDetails
  alias Pos.Plans

  schema "recharge_details" do
    field :expaired, :date
    field :planId, :string
    field :rechargeId, :string
    field :restaurentId, :string
    field :time, :time
    field :valid, :date

    timestamps()
  end

  def addRechargeDetails(expaired, plan_id, rechargeId, restaurentId, valid) do
    case Pos.Repo.get_by(RechargeDetails, restaurentId: restaurentId) do
      nil ->
          %Pos.RechargeDetails{
            expaired: expaired,
            planId: plan_id,
            rechargeId: rechargeId,
            restaurentId: restaurentId,
            valid: valid
          }
          |> Pos.Repo.insert()

          {:ok, true}
      rechargedata ->
        if rechargedata.valid <= valid and rechargedata.expaired >= valid do

          {:ok, false}
        else
          Pos.Repo.get_by(RechargeDetails, restaurentId: rechargedata.restaurentId)
          |> Ecto.Changeset.change(%{expaired: expaired, valid: valid})
          |> Pos.Repo.update()
          {:ok, true}
        end
    end
  end

  def getCurrentPlan(restaurentId,date) do
    from(r in RechargeDetails, where: r.restaurentId == ^restaurentId and r.expaired >= ^date and r.valid <= ^date, join: p in Plans, on: p.plan_id == r.planId,
                               select: %{name: p.name, price: p.price, rechargeId: r.rechargeId, valid: r.valid, expaired: r.expaired})
    |> Pos.Repo.all()
  end
  @doc false
  def changeset(recharge_details, attrs) do
    recharge_details
    |> cast(attrs, [:rechargeId, :restaurentId, :planId, :valid, :expaired, :time])
    |> validate_required([:rechargeId, :restaurentId, :planId, :valid, :expaired, :time])
  end
end

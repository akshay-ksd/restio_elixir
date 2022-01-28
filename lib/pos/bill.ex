defmodule Pos.Bill do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bill" do
    field :billId, :string
    field :date, :utc_datetime_usec
    field :planId, :string
    field :restaurentId, :string
    field :salesExicutiveId, :string

    timestamps()
  end

  def addBillDetails(rechargeId, date, plan_id, restaurentId, salesExicutiveId) do
    %Pos.Bill{
      billId: rechargeId,
      date: date,
      planId: plan_id,
      restaurentId: restaurentId,
      salesExicutiveId: salesExicutiveId}

    |> Pos.Repo.insert()
  end

  @doc false
  def changeset(bill, attrs) do
    bill
    |> cast(attrs, [:billId, :restaurentId, :planId, :salesExicutiveId, :date])
    |> validate_required([:billId, :restaurentId, :planId, :salesExicutiveId, :date])
  end
end

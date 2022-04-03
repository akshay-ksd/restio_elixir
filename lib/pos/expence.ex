defmodule Pos.Expence do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Expence
  alias Pos.Staff
  alias Pos.Queue

  schema "expence" do
    field :amount, :integer
    field :category, :string
    field :paymentType, :integer
    field :restaurentId, :string
    field :date, :string
    field :month, :integer
    field :year, :integer
    field :expenceId, :string
    timestamps()
  end

  def addExpence(restaurentId,paymentType,category,amount,date,month,year,expenceId) do
    %Pos.Expence{
      restaurentId: restaurentId,
      paymentType: paymentType,
      category: category,
      amount: amount,
      date: date,
      month: month,
      year: year,
      expenceId: expenceId
    }

    |> Pos.Repo.insert()
    access1 = "ALL"
    access2 = "MENU"

    accessid = expenceId
    restaurentId = restaurentId
    restaurent_id = restaurentId
    section = "Expence"
    task = "ADD"
    time = DateTime.utc_now()

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
       staffId = Enum.at(staffData, i)
       Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def updateExpence(restaurentId,paymentType,category,amount,expenceId) do
    Pos.Repo.get_by(Expence, restaurentId: restaurentId, expenceId: expenceId)
    |> Ecto.Changeset.change(%{ paymentType: paymentType, category: category, amount: amount})
    |> Pos.Repo.update()
    access1 = "ALL"
    access2 = "MENU"

    accessid = expenceId
    restaurentId = restaurentId
    restaurent_id = restaurentId
    section = "Expence"
    task = "UPDATE"
    time = DateTime.utc_now()

    Queue.deleteOldUpdate(restaurentId, section, task, accessid)

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
       staffId = Enum.at(staffData, i)
       Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def deleteExpence(restaurentId,expenceId) do
    data = Pos.Repo.get_by(Expence, restaurentId: restaurentId, expenceId: expenceId)
    Pos.Repo.delete(data)

    access1 = "ALL"
    access2 = "MENU"

    accessid = expenceId
    restaurentId = restaurentId
    restaurent_id = restaurentId
    section = "Expence"
    task = "DELETE"
    time = DateTime.utc_now()

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
       staffId = Enum.at(staffData, i)
       Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def getExpenceById(restaurentId,expenceId) do
    from(p in Expence, where: p.restaurentId == ^restaurentId and p.expenceId == ^expenceId,
                       select: %{amount: p.amount,category: p.category,paymentType: p.paymentType,restaurentId: p.restaurentId,
                                 date: p.date,month: p.month,year: p.year,expenceId: p.expenceId})
    |> Pos.Repo.all()
  end

  def getExpenceByRestaurentId(restaurentId) do
    from(p in Expence, where: p.restaurentId == ^restaurentId,
                       select: %{amount: p.amount,category: p.category,paymentType: p.paymentType,restaurentId: p.restaurentId,
                                 date: p.date,month: p.month,year: p.year,expenceId: p.expenceId})
    |> Pos.Repo.all()
  end

  def getExpenceBydate(restaurentId,date) do
      from(p in Expence, where: p.restaurentId == ^restaurentId and p.date == ^date,
      select: %{amount: p.amount,category: p.category,paymentType: p.paymentType,restaurentId: p.restaurentId,
                date: p.date,month: p.month,year: p.year,expenceId: p.expenceId})
      |> Pos.Repo.all()
  end



  @doc false
  def changeset(expence, attrs) do
    expence
    |> cast(attrs, [:restaurentId, :amount, :category, :paymentType, :date, :month, :year, :expenceId])
    |> validate_required([:restaurentId, :amount, :category, :paymentType, :date, :month, :year, :expenceId])
  end
end

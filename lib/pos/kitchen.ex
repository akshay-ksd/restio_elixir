defmodule Pos.Kitchen do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Kitchen
  alias Pos.Staff
  alias Pos.Queue

  schema "kitchen" do
    field :date, :integer
    field :kitchenId, :string
    field :note, :string
    field :orderId, :string
    field :restaurentId, :string
    field :stafId, :string
    field :status, :string
    field :time, :string

    timestamps()
  end

  def insertOrderData(date, kitchenId, note, orderId, restaurentId, stafId, status, time) do

    %Pos.Kitchen{
      date: date,
      kitchenId: kitchenId,
      note: note,
      orderId: orderId,
      restaurentId: restaurentId,
      stafId: stafId,
      status: status,
      time: time
    }

    |> Pos.Repo.insert()

    access1 = "ALL"
    access2 = "MENU"

    accessid = kitchenId
    section = "Kitchen"
    task = "ADD"
    staffId = stafId
    restaurent_id = restaurentId
    time = DateTime.utc_now()

    Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)

    adminStaffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(adminStaffData)

    for i <- 0..count-1, i >= 0 do
      staffId = Enum.at(adminStaffData, i)
      Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def updateStatus(kitchenId,restaurentId, status) do
    Pos.Repo.get_by(Kitchen, kitchenId: kitchenId, restaurentId: restaurentId)
    |> Ecto.Changeset.change(%{ status: status})
    |> Pos.Repo.update()

    access1 = "ALL"
    access2 = "MENU"

    accessid = kitchenId
    section = "Kitchen"
    task = "UPDATE"
    restaurent_id = restaurentId
    time = DateTime.utc_now()

    adminStaffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(adminStaffData)

    for i <- 0..count-1, i >= 0 do
      staffId = Enum.at(adminStaffData, i)
      Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def getKitchenData(restaurentId,kitchenId) do
    from(p in Kitchen, where: p.restaurentId == ^restaurentId and p.kitchenId == ^kitchenId,
    select: %{date: p.date, kitchenId: p.kitchenId, note: p.note, stafId: p.stafId, status: p.status, time: p.time, orderId: p.orderId, restaurentId: p.restaurentId})
    |> Pos.Repo.all()
  end

  def getKichenDataByRestaurentId(restaurentId) do
    from(p in Kitchen, where: p.restaurentId == ^restaurentId,
    select: %{date: p.date, kitchenId: p.kitchenId, note: p.note, stafId: p.stafId, status: p.status, time: p.time, orderId: p.orderId, restaurentId: p.restaurentId})
    |> Pos.Repo.all()
  end

  @doc false
  def changeset(kitchen, attrs) do
    kitchen
    |> cast(attrs, [:kitchenId, :restaurentId, :orderId, :time, :date, :stafId, :note, :status])
    |> validate_required([:kitchenId, :restaurentId, :orderId, :time, :date, :stafId, :note, :status])
  end
end

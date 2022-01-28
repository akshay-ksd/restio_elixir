defmodule Pos.KitchenDetails do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.KitchenDetails
  alias Pos.Queue
  alias Pos.Staff
  require Logger

  schema "kitchen_details" do
    field :kitchenId, :string
    field :productId, :string
    field :quantity, :integer
    field :restaurentId, :string
    field :name, :string
    field :kitchen_details, :string

    timestamps()
  end
  def insertKitchenDetails(kitchenId, pId, quantity, restaurentId, name, kitchen_details, task, stafId) do
    %Pos.KitchenDetails{
        kitchenId: kitchenId,
        productId: pId,
        quantity: quantity,
        restaurentId: restaurentId,
        name: name,
        kitchen_details: kitchen_details
    }

    |> Pos.Repo.insert()

    if task == "ADD" do
        access1 = "ALL"
        access2 = "MENU"

        accessid = kitchen_details
        section = "kitchen_details"
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
  end

  def deleteProduct(kitchenId, restaurentId, stafId, kitchen_details) do
    data = Pos.Repo.get_by(KitchenDetails, restaurentId: restaurentId, kitchenId: kitchenId, kitchen_details: kitchen_details)
    Pos.Repo.delete(data)

    access1 = "ALL"
    access2 = "MENU"

    accessid = kitchen_details
    section = "kitchen_details"
    task = "DELETE"
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

  def getKitchenDetails(kitchenId,restaurentId) do
    from(p in KitchenDetails, where: p.restaurentId == ^restaurentId and p.kitchenId == ^kitchenId,
    select: %{kitchenId: p.kitchenId, restaurentId: p.restaurentId, id: p.productId, quantity: p.quantity, name: p.name, kitchen_details: p.kitchen_details})
    |> Pos.Repo.all()
  end

  def getKitchenDetailsByKitchennDetails(restaurentId,kitchen_details) do
    from(p in KitchenDetails, where: p.restaurentId == ^restaurentId and p.kitchen_details == ^kitchen_details,
    select: %{kitchenId: p.kitchenId, restaurentId: p.restaurentId, id: p.productId, quantity: p.quantity, name: p.name, kitchen_details: p.kitchen_details})
    |> Pos.Repo.all()
  end

  def getKitchenDetailsByRestaurentId(restaurentId) do
    from(p in KitchenDetails, where: p.restaurentId == ^restaurentId,
    select: %{kitchenId: p.kitchenId, restaurentId: p.restaurentId, id: p.productId, quantity: p.quantity, name: p.name, kitchen_details: p.kitchen_details})
    |> Pos.Repo.all()
  end

  @doc false
  def changeset(kitchen_details, attrs) do
    kitchen_details
    |> cast(attrs, [:kitchenId, :productId, :quantity, :restaurentId, :name, :kitchen_details])
    |> validate_required([:kitchenId, :productId, :quantity, :restaurentId, :name, :kitchen_details])
  end
end

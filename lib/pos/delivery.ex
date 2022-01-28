defmodule Pos.Delivery do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Delivery
  alias Pos.Order
  alias Pos.Product
  alias Pos.Queue
  alias Pos.Staff
  require Logger

  schema "delivery" do
    field :address, :string
    field :delivery_id, :string
    field :delivery_time, :string
    field :name, :string
    field :number, :string
    field :order_id, :string
    field :order_time, :string
    field :restaurent_id, :string
    field :staff_id, :string
    field :status, :string
    field :gst, :float
    field :charge, :float

    timestamps()
  end

  def addOrder(address,delivery_id,delivery_time,name,number,order_id,order_time,restaurent_id,staff_id,status,gst,charge) do
    time = DateTime.utc_now()

    %Pos.Delivery{
     address: address,
     delivery_id: delivery_id,
     delivery_time: delivery_time,
     name: name,
     number: number,
     order_id: order_id,
     order_time: order_time,
     restaurent_id: restaurent_id,
     staff_id: staff_id,
     status: status,
     gst: gst,
     charge: charge
    }

    |> Pos.Repo.insert()

    access1 = "ALL"
    access2 = "MENU"

    accessid = delivery_id
    restaurentId = restaurent_id
    section = "Delivery"
    task = "ADD"
    staffId = staff_id

    Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)

    adminStaffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(adminStaffData)

    for i <- 0..count-1, i >= 0 do
      staffId = Enum.at(adminStaffData, i)
      Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def deleteDelivery(orderId, restaurentId, staffId, deliveryId) do
    time = DateTime.utc_now()

    data = Pos.Repo.get_by(Delivery, order_id: orderId, restaurent_id: restaurentId)
    Pos.Repo.delete(data)
    access1 = "ALL"
    access2 = "MENU"

    accessid = deliveryId
    section = "Delivery"
    task = "DELETE"
    staffId = staffId
    restaurent_id = restaurentId

    Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)

    adminStaffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(adminStaffData)

    for i <- 0..count-1, i >= 0 do
      staffId = Enum.at(adminStaffData, i)
      Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def getDeliveryDetails(order_id) do
    from(p in Order, where: p.order_id == ^order_id, join: d in Product, on: p.product_id == d.product_id,
         select: %{name: d.name, price: p.price, is_veg: d.is_veg, description: d.description, quantity: p.quantity, product_id: d.product_id, order_detail_id: p.order_detail_id, total: (p.quantity*p.price)})

    |> Pos.Repo.all()
  end

  def updateStaus(orderId, restaurent_id, deliveryId, status) do
    time = DateTime.utc_now()

    Pos.Repo.get_by(Delivery, order_id: orderId, delivery_id: deliveryId, restaurent_id: restaurent_id)
    |> Ecto.Changeset.change(%{ status: status})
    |> Pos.Repo.update()

    access1 = "ALL"
    access2 = "MENU"

    accessid = deliveryId
    restaurentId = restaurent_id
    section = "Delivery"
    task = "UPDATE"

    adminStaffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(adminStaffData)

    for i <- 0..count-1, i >= 0 do
      staffId = Enum.at(adminStaffData, i)
      Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def getdelivery(restaurentId,deliveryId) do
    from(p in Delivery, where: p.delivery_id == ^deliveryId and p.restaurent_id == ^restaurentId,
                        select: %{address: p.address, delivery_id: p.delivery_id, delivery_time: p.delivery_time, name: p.name, number: p.number, order_id: p.order_id,
                                  order_time: p.order_time, restaurent_id: p.restaurent_id, staff_id: p.staff_id, status: p.status, gst: p.gst, charge: p.charge}) |> Pos.Repo.all()
  end

  def getDeliveryDataByRestaurentId(restaurentId) do
    from(p in Delivery, where: p.restaurent_id == ^restaurentId,
    select: %{address: p.address, delivery_id: p.delivery_id, delivery_time: p.delivery_time, name: p.name, number: p.number, order_id: p.order_id,
              order_time: p.order_time, restaurent_id: p.restaurent_id, staff_id: p.staff_id, status: p.status, gst: p.gst, charge: p.charge}) |> Pos.Repo.all()
  end

  def getDeliveryDataByStaffId(restaurentId,userId) do
    from(p in Delivery, where: p.restaurent_id == ^restaurentId and p.staff_id == ^userId,
    select: %{address: p.address, delivery_id: p.delivery_id, delivery_time: p.delivery_time, name: p.name, number: p.number, order_id: p.order_id,
              order_time: p.order_time, restaurent_id: p.restaurent_id, staff_id: p.staff_id, status: p.status, gst: p.gst, charge: p.charge}) |> Pos.Repo.all()
  end

  @doc false
  def changeset(delivery, attrs) do
    delivery
    |> cast(attrs, [:delivery_id, :order_id, :staff_id, :restaurent_id, :order_time, :delivery_time, :name, :address, :number, :status, :gst, :charge])
    |> validate_required([:delivery_id, :order_id, :staff_id, :restaurent_id, :order_time, :delivery_time, :name, :address, :number, :status, :gst, :charge])
  end
end

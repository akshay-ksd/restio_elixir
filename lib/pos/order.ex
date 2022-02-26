defmodule Pos.Order do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Order
  alias Pos.Queue
  alias Pos.Staff
  require Logger

  schema "order" do
    field :order_detail_id, :string
    field :order_id, :string
    field :price, :integer
    field :product_id, :string
    field :quantity, :integer
    field :restaurent_id, :string
    field :name, :string
    field :isVeg, :integer

    timestamps()
  end

  def insertOrderData(order_detail_id,order_id,price,product_id,quantity,restaurent_id,name,isVeg) do
    %Pos.Order{
      order_detail_id: order_detail_id,
      order_id: order_id,
      price: price,
      product_id: product_id,
      quantity: quantity,
      restaurent_id: restaurent_id,
      name: name,
      isVeg: isVeg
    }

    |> Pos.Repo.insert()

  end

  def insertSingleOrderData(order_detail_id,order_id,price,product_id,quantity,restaurent_id) do
    %Pos.Order{
      order_detail_id: order_detail_id,
      order_id: order_id,
      price: price,
      product_id: product_id,
      quantity: quantity,
      restaurent_id: restaurent_id,
    }

    |> Pos.Repo.insert()

      access1 = "ALL"
      access2 = "MENU"
      time = DateTime.utc_now()

      accessid = order_detail_id
      restaurentId = restaurent_id
      section = "Order"
      task = "PRODUCT_ADD"

      staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
      count = Enum.count(staffData)

      for i <- 0..count-1, i >= 0 do
        staffId = Enum.at(staffData, i)
        Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
      end
  end

  def updateOrderData(order_detail_id,order_id,quantity,restaurent_id) do
    Pos.Repo.get_by(Order, order_detail_id: order_detail_id, order_id: order_id,restaurent_id: restaurent_id)
    |> Ecto.Changeset.change(%{quantity: quantity})
    |> Pos.Repo.update()

    access1 = "ALL"
    access2 = "MENU"
    time = DateTime.utc_now()

    accessid = order_detail_id
    restaurentId = restaurent_id
    section = "Order"
    task = "PRODUCT_UPDATE"

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
      staffId = Enum.at(staffData, i)
      Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def deleteOrderData(order_detail_id,order_id,restaurent_id) do
    data = Pos.Repo.get_by(Order, restaurent_id: restaurent_id,order_detail_id: order_detail_id,order_id: order_id)
    Pos.Repo.delete(data)

    access1 = "ALL"
    access2 = "MENU"
    time = DateTime.utc_now()

    accessid = order_detail_id
    restaurentId = restaurent_id
    section = "Order"
    task = "PRODUCT_DELETE"

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
      staffId = Enum.at(staffData, i)
      Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def getOrderDetailsById(restaurentId, orderId) do
    from(p in Order, where: p.restaurent_id == ^restaurentId and p.order_id == ^orderId,
    select: %{order_detail_id: p.order_detail_id, order_id: p.order_id, price: p.price, product_id: p.product_id, quantity: p.quantity, restaurent_id: p.restaurent_id, name: p.name, isVeg: p.isVeg})
    |> Pos.Repo.all()
  end

  def getOrderDetailsByRestaurentId(restaurentId) do
    from(p in Order, where: p.restaurent_id == ^restaurentId,
    select: %{order_detail_id: p.order_detail_id, order_id: p.order_id, price: p.price, product_id: p.product_id, quantity: p.quantity, restaurent_id: p.restaurent_id, name: p.name, isVeg: p.isVeg})
    |> Pos.Repo.all()
  end

  def getOrderDetailsByDetailId(order_detail_id, restaurentId) do
    from(p in Order, where: p.restaurent_id == ^restaurentId and p.order_detail_id == ^order_detail_id,
    select: %{order_detail_id: p.order_detail_id, order_id: p.order_id, price: p.price, product_id: p.product_id, quantity: p.quantity, restaurent_id: p.restaurent_id, name: p.name, isVeg: p.isVeg})
    |> Pos.Repo.all()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_detail_id, :order_id, :product_id, :quantity, :price, :restaurent_id, :name, :isVeg])
    |> validate_required([:order_detail_id, :order_id, :product_id, :quantity, :price, :restaurent_id, :name, :isVeg])
  end
end

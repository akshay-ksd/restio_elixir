defmodule Pos.Order do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Order
  require Logger

  schema "order" do
    field :order_detail_id, :string
    field :order_id, :string
    field :price, :integer
    field :product_id, :string
    field :quantity, :integer
    field :restaurent_id, :string

    timestamps()
  end

  def insertOrderData(order_detail_id,order_id,price,product_id,quantity,restaurent_id) do
    %Pos.Order{
      order_detail_id: order_detail_id,
      order_id: order_id,
      price: price,
      product_id: product_id,
      quantity: quantity,
      restaurent_id: restaurent_id,
    }

    |> Pos.Repo.insert()

    Logger.info "insert"
  end

  def updateOrderData(order_detail_id,order_id,quantity,restaurent_id) do
    Pos.Repo.get_by(Order, order_detail_id: order_detail_id, order_id: order_id,restaurent_id: restaurent_id)
    |> Ecto.Changeset.change(%{quantity: quantity})
    |> Pos.Repo.update()
    Logger.info "update"
  end

  def deleteOrderData(order_detail_id,order_id,restaurent_id) do
    data = Pos.Repo.get_by(Order, restaurent_id: restaurent_id,order_detail_id: order_detail_id,order_id: order_id)
    Pos.Repo.delete(data)
    Logger.info "delete"
  end

  def getOrderDetailsById(restaurentId, orderId) do
    from(p in Order, where: p.restaurent_id == ^restaurentId and p.order_id == ^orderId,
    select: %{order_detail_id: p.order_detail_id, order_id: p.order_id, price: p.price, product_id: p.product_id, quantity: p.quantity, restaurent_id: p.restaurent_id})
    |> Pos.Repo.all()
  end

  def getOrderDetailsByRestaurentId(restaurentId) do
    from(p in Order, where: p.restaurent_id == ^restaurentId,
    select: %{order_detail_id: p.order_detail_id, order_id: p.order_id, price: p.price, product_id: p.product_id, quantity: p.quantity, restaurent_id: p.restaurent_id})
    |> Pos.Repo.all()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:order_detail_id, :order_id, :product_id, :quantity, :price, :restaurent_id])
    |> validate_required([:order_detail_id, :order_id, :product_id, :quantity, :price, :restaurent_id])
  end
end

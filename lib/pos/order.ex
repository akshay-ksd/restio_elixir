defmodule Pos.Order do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Order

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

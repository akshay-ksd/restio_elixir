defmodule Pos.Product do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Product
  alias Pos.Staff
  alias Pos.Queue
  require Logger

  schema "product" do
    field :category_id, :string
    field :description, :string
    field :name, :string
    field :price, :integer
    field :product_id, :string
    field :restaurent_id, :string
    field :stock, :integer
    field :is_veg, :integer
    field :isHide, :boolean
    timestamps()
  end

  def addProduct(product_id,category_id,restaurent_id,name,description,price,stock,is_veg) do
    time = DateTime.utc_now()
    %Pos.Product{
      category_id: category_id,
      description: description,
      name: name,
      price: price,
      product_id: product_id,
      restaurent_id: restaurent_id,
      stock: stock,
      is_veg: is_veg,
      isHide: false
    }
    |> Pos.Repo.insert()
    access1 = "ALL"
    access2 = "MENU"

    accessid = product_id
    restaurentId = restaurent_id
    section = "Product"
    task = "ADD"

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
       staffId = Enum.at(staffData, i)
       Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def updateProduct(product_id,category_id,restaurent_id,name,description,price,stock,is_veg,isHide) do
    time = DateTime.utc_now()

    Pos.Repo.get_by(Product, restaurent_id: restaurent_id, product_id: product_id)
    |> Ecto.Changeset.change(%{
                                description: description,
                                name: name,
                                price: price,
                                stock: stock,
                                is_veg: is_veg,
                                isHide: isHide,
                                category_id: category_id
                              })
    |> Pos.Repo.update()

    access1 = "ALL"
    access2 = "MENU"

    accessid = product_id
    restaurentId = restaurent_id
    section = "Product"
    task = "UPDATE"

    Queue.deleteOldUpdate(restaurentId, section, task, accessid)

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
       staffId = Enum.at(staffData, i)
       Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def deleteProduct(product_id, restaurent_id,isHide) do
    time = DateTime.utc_now()
    Pos.Repo.get_by(Product, restaurent_id: restaurent_id, product_id: product_id)
    |> Ecto.Changeset.change(%{
                                isHide: isHide
                              })
    |> Pos.Repo.update()

    access1 = "ALL"
    access2 = "MENU"

    accessid = product_id
    restaurentId = restaurent_id
    section = "Product"
    task = "DELETE"

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
       staffId = Enum.at(staffData, i)
       Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def getProductDataById(productId, restaurentId) do
    from(p in Product, where: p.product_id == ^productId and p.restaurent_id == ^restaurentId,
    select: %{category_id: p.category_id, description: p.description, name: p.name, price: p.price, product_id: p.product_id, restaurent_id: p.restaurent_id,
              stock: p.stock, is_veg: p.is_veg, isHide: p.isHide})

    |> Pos.Repo.all()
  end

  def getProductByRestaurenId(restaurentId) do
    from(p in Product, where: p.restaurent_id == ^restaurentId,
                       select: %{category_id: p.category_id, description: p.description, name: p.name, price: p.price, product_id: p.product_id, restaurent_id: p.restaurent_id,
                                 stock: p.stock, is_veg: p.is_veg, isHide: p.isHide})

    |> Pos.Repo.all()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:product_id, :category_id, :name, :description, :price, :stock, :restaurent_id, :is_veg, :isHide])
    |> validate_required([:product_id, :category_id, :name, :description, :price, :stock, :restaurent_id, :is_veg, :isHide])
  end
end

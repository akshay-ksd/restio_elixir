defmodule Pos.Category do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Staff
  alias Pos.Queue
  alias Pos.Category

  schema "category" do
    field :categoryName, :string
    field :category_id, :string
    field :restaurent_id, :string

    timestamps()
  end

  def addCategory(categoryName,category_id,restaurent_id) do
      time = DateTime.utc_now()
      %Pos.Category{
          categoryName: categoryName,
          category_id: category_id,
          restaurent_id: restaurent_id,
      } |> Pos.Repo.insert()

      access1 = "ALL"
      access2 = "MENU"

      accessid = category_id
      restaurentId = restaurent_id
      section = "Menu"
      task = "ADD"

      staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
      count = Enum.count(staffData)

      for i <- 0..count-1, i >= 0 do
        staffId = Enum.at(staffData, i)
        Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
      end
  end

  def getCategoryDataById(menuId, restaurentId) do
    from(p in Category, where: p.category_id == ^menuId and p.restaurent_id == ^restaurentId,
                        select: %{categoryName: p.categoryName, category_id: p.category_id, restaurent_id: p.restaurent_id}) |> Pos.Repo.all()
  end

  def getCategoryByRestaurentId(restaurentId) do
    from(p in Category, where: p.restaurent_id == ^restaurentId,
                        select: %{categoryName: p.categoryName, category_id: p.category_id, restaurent_id: p.restaurent_id}) |> Pos.Repo.all()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:category_id, :categoryName, :restaurent_id])
    |> validate_required([:category_id, :categoryName, :restaurent_id])
  end
end

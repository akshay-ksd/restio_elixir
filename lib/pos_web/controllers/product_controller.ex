defmodule PosWeb.ProductController do
  use PosWeb, :controller
  alias Pos.Product
  alias Pos.Category

  def getProductData(conn, %{"restaurentId" => restaurentId}) do
    menu = Category.getCategoryByRestaurentId(restaurentId)
    product = Product.getProductByRestaurenId(restaurentId)
    conn
    |> json(%{
      "restaurentId" => restaurentId,
      "menu" => menu,
      "product" => product,
    })
  end
end

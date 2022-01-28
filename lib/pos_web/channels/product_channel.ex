defmodule PosWeb.ProductChannel do
  use PosWeb, :channel
  intercept ["addProduct","updateProduct","deleteQue","deleteProduct","checkQueue"]
  alias Pos.Product
  alias Pos.Queue
  require Logger

  def join("product:" <> _restaurentid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("addProduct", %{"product" => product}, socket) do
    product_id = product["product_id"]
    category_id = product["category_id"]
    restaurent_id = product["restaurent_id"]
    name = product["name"]
    description = product["description"]
    price = String.to_integer(product["price"])
    stock = String.to_integer(product["stock"])
    is_veg = product["is_veg"]

    Product.addProduct(product_id,category_id,restaurent_id,name,description,price,stock,is_veg)
    broadcast!(socket, "addProduct", %{"product" => product})

    {:noreply, socket}
  end

  def handle_in("updateProduct", %{"product" => product}, socket) do
    product_id = product["product_id"]
    category_id = product["category_id"]
    restaurent_id = product["restaurent_id"]
    name = product["name"]
    description = product["description"]
    price = String.to_integer(product["price"])
    stock = String.to_integer(product["stock"])
    is_veg = product["is_veg"]
    isHide = product["isHide"]

    Product.updateProduct(product_id, category_id, restaurent_id, name, description, price, stock, is_veg, isHide)
    broadcast!(socket, "updateProduct", %{"product" => product})

    {:noreply, socket}
  end

  def handle_in("deleteProduct",  %{"product" => product}, socket) do
    product_id = product["product_id"]
    restaurent_id = product["restaurent_id"]
    isHide = product["isHide"]
    Product.deleteProduct(product_id, restaurent_id,isHide)
    broadcast!(socket, "deleteProduct", %{"product" => product})

    {:noreply, socket}
  end

  def handle_in("deleteQue", %{"data" => data}, socket) do
    staffId = data["uToken"]
    restaurentId = data["rToken"]
    accessid = data["accessid"]
    task = data["task"]

    Queue.deleteQue(restaurentId,staffId,accessid,task)

    # status = "Success"
    # broadcast!(socket, "deleteQue", %{"status" => status})
    {:noreply, socket}
  end

  def handle_in("checkQueue", %{"data" => data}, socket) do
    staffId = data["utoken"]
    restaurentId = data["rtoken"]
    section = data["section"]
    task = data["task"]
    queue_data = Queue.getQueue(restaurentId, staffId, section, task)
    count = Enum.count(queue_data)
    if count !== 0 do
      for i <- 0..count-1, i >= 0 do
        productId =  Enum.at(queue_data, i)
        product = Product.getProductDataById(productId, restaurentId)
        broadcast!(socket, "checkQueue", %{"data" => product,"task" => task,"staffId" => staffId})
      end
    else
      broadcast!(socket, "checkQueue", %{"data" => false,"task" => task,"staffId" => staffId})
    end
    {:noreply, socket}
  end







  def handle_out("addProduct", payload, socket) do
    push(socket, "addProduct", payload)
    {:noreply, socket}
  end

  def handle_out("updateProduct", payload, socket) do
    push(socket, "updateProduct", payload)
    {:noreply, socket}
  end

  def handle_out("deleteProduct", payload, socket) do
    push(socket, "deleteProduct", payload)
    {:noreply, socket}
  end

  def handle_out("deleteQue", payload, socket) do
    push(socket, "deleteQue", payload)
    {:noreply, socket}
  end

  def handle_out("checkQueue", payload, socket) do
    push(socket, "checkQueue", payload)
    {:noreply, socket}
  end
end

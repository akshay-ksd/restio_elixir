defmodule PosWeb.MenuChannel do
  use PosWeb, :channel
  alias Pos.Category
  intercept ["addCategory","deleteCategory"]
  alias Pos.Category
  alias Pos.Queue
  # intercept ["deleteCategory"]

  def join("menu:" <> _restaurentid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("addCategory", %{"category" => category}, socket) do

     categoryName = category["categoryName"]
     category_id = category["category_id"]
     restaurent_id = category["restaurent_id"]

     Category.addCategory(categoryName,category_id,restaurent_id)

     broadcast!(socket, "addCategory", %{category_name: category})

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
        menuId =  Enum.at(queue_data, i)
        menu = Category.getCategoryDataById(menuId, restaurentId)
        broadcast!(socket, "checkQueue", %{"data" => menu,"staffId" => staffId})
      end
    end

    {:noreply, socket}
  end

  def handle_in("deleteQue", %{"data" => data}, socket) do
    staffId = data["uToken"]
    restaurentId = data["rToken"]
    accessid = data["accessid"]
    task = data["task"]

    Queue.deleteQue(restaurentId, staffId, accessid, task)
    status = "Success"
    broadcast!(socket, "deleteQue", %{"status" => status})
    {:noreply, socket}
  end







  def handle_out("addCategory", payload, socket) do
    push(socket, "new_category", payload)
    {:noreply, socket}
  end

  def handle_in("deleteCategory", %{"category" => category}, socket) do
    broadcast!(socket, "deleteCategory", %{category_id: category})
    {:noreply, socket}
  end

  def handle_out("deleteCategory", payload, socket) do
    push(socket, "deleteCategory", payload)
    {:noreply, socket}
  end

  def handle_out("checkQueue", payload, socket) do
    push(socket, "checkQueue", payload)
    {:noreply, socket}
  end

  def handle_out("deleteQue", payload, socket) do
    push(socket, "deleteQue", payload)
    {:noreply, socket}
  end
end

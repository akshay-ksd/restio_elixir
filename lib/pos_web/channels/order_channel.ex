defmodule PosWeb.OrderChannel do
  use PosWeb, :channel
  intercept ["addOrder"]
  alias Pos.OrderMaster
  alias Pos.Order
  alias Pos.Queue
  require Logger

  def join("order:" <> _restaurentid, _params, socket) do
      {:ok, %{"status" => true}, socket}
  end

  def handle_in("addOrder", %{"order_data" => order_data}, socket) do

    date = order_data["date"]
    order_id = order_data["order_id"]
    restaurent_id = order_data["restaurent_id"]
    status = order_data["status"]
    otime = order_data["time"]
    user_id = order_data["user_id"]
    product = order_data["product"]
    charge = order_data["charge"]
    gst = order_data["gst"]

    OrderMaster.insertOrderMasterData(date,order_id,restaurent_id,status,otime,user_id,gst,charge)

    count = length(product)
    for i <- 0..count-1, i >= 0 do
      product_data = Enum.at(order_data["product"] |> List.flatten(), i)

      order_detail_id = product_data["order_detail_id"]
      order_id = product_data["order_id"]
      price = product_data["price"]
      product_id = product_data["product_id"]
      quantity = product_data["quantity"]
      restaurent_id = product_data["restaurent_id"]

      Order.insertOrderData(order_detail_id,order_id,price,product_id,quantity,restaurent_id)
    end

    broadcast!(socket, "addOrder", %{product: order_data})
    {:noreply, socket}
  end

  def handle_in("updateStatus", %{"order_data" => order_data}, socket) do
    order_id = order_data["order_id"]
    status = order_data["status"]
    restaurent_id = order_data["restaurent_id"]

    OrderMaster.updateOrderStatus(order_id,status,restaurent_id)

    broadcast!(socket, "addOrder", %{product: order_data})
    {:noreply, socket}
  end

  def handle_in("deleteQue", %{"data" => data}, socket) do
    staffId = data["uToken"]
    restaurentId = data["rToken"]
    accessid = data["accessid"]
    task = data["task"]

    Queue.deleteQue(restaurentId, staffId, accessid, task)
    broadcast!(socket, "deleteQue", %{status: true})
    {:noreply, socket}
  end

  def handle_in("updateOrder", %{"order_data" => order_data}, socket) do
    order_id = order_data["order_id"]
    restaurent_id = order_data["restaurent_id"]
    product = order_data["product"]
    charge = order_data["charge"]
    gst = order_data["gst"]

    count = length(product)

    OrderMaster.updateOrderData(order_id, restaurent_id, gst, charge)
    for i <- 0..count-1, i >= 0 do
      product_data = Enum.at(order_data["product"] |> List.flatten(), i)

      order_detail_id = product_data["order_detail_id"]
      order_id = product_data["order_id"]
      price = product_data["price"]
      product_id = product_data["product_id"]
      quantity = product_data["quantity"]
      restaurent_id = product_data["restaurent_id"]
      task = product_data["task"]

      cond do
        task == "INSERT" ->
         Order.insertSingleOrderData(order_detail_id,order_id,price,product_id,quantity,restaurent_id)

        task == "UPDATE" ->
         Order.updateOrderData(order_detail_id, order_id, quantity, restaurent_id)

        task == "DELETE" ->
          Order.deleteOrderData(order_detail_id, order_id, restaurent_id)
      end
    end

    broadcast!(socket, "updateOrder", %{product: order_data})
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

      cond do
        task == "ADD" or task == "UPDATE" ->
          for i <- 0..count-1, i >= 0 do
              orderId =  Enum.at(queue_data, i)
              order = OrderMaster.getOrderById(restaurentId, orderId)
              order_details = Order.getOrderDetailsById(restaurentId, orderId)

              broadcast!(socket, "checkQueue", %{"order" => order,"order_details" => order_details,"task" => task,"staffId" => staffId})
          end

        task == "PRODUCT_ADD" or  task == "PRODUCT_UPDATE" ->
          for i <- 0..count-1, i >= 0 do
            order_detail_id =  Enum.at(queue_data, i)
            order = Order.getOrderDetailsByDetailId(order_detail_id, restaurentId)
            Logger.info order
            broadcast!(socket, "checkQueue", %{"order" => false,"order_details" => order,"task" => task,"staffId" => staffId})
          end

        task == "PRODUCT_DELETE" ->
          for i <- 0..count-1, i >= 0 do
            order_detail_id =  Enum.at(queue_data, i)

            broadcast!(socket, "checkQueue", %{"order" => false,"order_details" => order_detail_id,"task" => task,"staffId" => staffId})
          end
      end

    else
      broadcast!(socket, "checkQueue", %{"order" => false,"order_details" => false,"task" => task,"staffId" => staffId})
    end
    {:noreply, socket}
  end

  def handle_out("addOrder", payload, socket) do
    push(socket, "addOrder", payload)
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

  def handle_out("updateOrder", payload, socket) do
    push(socket, "checkQueue", payload)
    {:noreply, socket}
  end
end

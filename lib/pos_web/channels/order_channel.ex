defmodule PosWeb.OrderChannel do
  use PosWeb, :channel
  intercept ["addOrder","getOrder"]
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
    tableNumber = order_data["tableNumber"]
    total = order_data["total"]

    year = order_data["year"]
    month = order_data["month"]
    day = order_data["day"]
    hour = order_data["hour"]
    minute = order_data["minute"]
    second = order_data["second"]

    order_date = %DateTime{year: year, month: month, day: day, zone_abbr: "UTC",
                           hour: hour, minute: minute, second: second, microsecond: {444632, 6},
                           utc_offset: 0, std_offset: 0, time_zone: "Etc/UTC"}
    OrderMaster.insertOrderMasterData(date,order_id,restaurent_id,status,otime,user_id,gst,charge,tableNumber,order_date,total,year,month,day)

    count = length(product)
    for i <- 0..count-1, i >= 0 do
      product_data = Enum.at(order_data["product"] |> List.flatten(), i)

      order_detail_id = product_data["order_detail_id"]
      order_id = product_data["order_id"]
      price = product_data["price"]
      product_id = product_data["product_id"]
      quantity = product_data["quantity"]
      restaurent_id = product_data["restaurent_id"]
      name = product_data["name"]
      isVeg = product_data["isVeg"]
      category_id = product_data["category_id"]

      Order.insertOrderData(order_detail_id, order_id, price, product_id, quantity, restaurent_id, name, isVeg, category_id)
    end
    broadcast!(socket, "addOrder", %{product: order_data})
    {:reply, :ok, socket}
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
    tableNumber = order_data["tableNumber"]
    total = order_data["total"]

    count = length(product)

    OrderMaster.updateOrderData(order_id, restaurent_id, gst, charge, tableNumber, total)
    for i <- 0..count-1, i >= 0 do
      product_data = Enum.at(order_data["product"] |> List.flatten(), i)

      order_detail_id = product_data["order_detail_id"]
      order_id = product_data["order_id"]
      price = product_data["price"]
      name = product_data["name"]
      isVeg = product_data["isVeg"]
      product_id = product_data["product_id"]
      quantity = product_data["quantity"]
      restaurent_id = product_data["restaurent_id"]
      task = product_data["task"]
      category_id = product_data["category_id"]
      cond do
        task == "INSERT" ->
         Order.insertSingleOrderData(order_detail_id,order_id,price,product_id,quantity,restaurent_id,name,isVeg,category_id)

        task == "UPDATE" ->
         Order.updateOrderData(order_detail_id, order_id, quantity, restaurent_id)

        task == "DELETE" ->
          Order.deleteOrderData(order_detail_id, order_id, restaurent_id)
      end
    end

    broadcast!(socket, "updateOrder", %{product: order_data})
    {:reply, :ok, socket}
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
            ocount = Enum.count(order)

            if ocount !== 0 do
                for o <- 0..ocount-1, o >= 0  do
                    order_data = Enum.at(order, o)
                    data_order = Enum.at(order_data, 3)
                    orderId = elem(data_order, 1)
                    order_master = OrderMaster.getOrderById(restaurentId, orderId)

                    broadcast!(socket, "checkQueue", %{"order" => order_master,"order_details" => order,"task" => task,"staffId" => staffId})
                end
            else
              broadcast!(socket, "checkQueue", %{"order" => false,"order_details" => order,"task" => task,"staffId" => staffId})
            end
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

  def handle_in("getOrder", %{"data" => data}, socket) do
    offset = data["offset"]
    limit = data["limit"]
    restaurentId = data["restaurentId"]
    filterType = data["filterType"]

    date = data["date"]

    order_master_data = OrderMaster.getOrderByPagination(restaurentId,limit,offset,filterType,date)

    count = Enum.count(order_master_data)

            if count !== 0 do
                for o <- 0..count-1, o >= 0  do
                    order_data = Enum.at(order_master_data, o)
                    data_order = Enum.at(order_data, 5)
                    orderId = elem(data_order, 1)
                    order_details_data = Order.getOrderDetailsById(restaurentId, orderId)
                    s_data = %{"data" => order_data,"order_details_data" => order_details_data}
                    broadcast!(socket, "getOrder", %{"data" => s_data})
                end
            else
                s_data = %{"data" => false}
                broadcast!(socket, "getOrder", %{"data" => s_data})
            end
            Enum.reduce order_master_data, %{}, fn x, acc ->
              dater = Enum.at(x, 5)
              id = elem(dater, 1)
              Logger.info(id)
              Map.put(acc, x, x)
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

  def handle_out("getOrder", payload, socket) do
    push(socket, "getOrder", payload)
    {:noreply, socket}
  end
end

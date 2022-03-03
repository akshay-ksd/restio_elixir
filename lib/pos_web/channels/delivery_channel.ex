defmodule PosWeb.DeliveryChannel do
  use PosWeb, :channel
  alias Pos.Delivery
  alias PosWeb.Presence
  alias Pos.Queue
  alias Pos.Order
  require Logger

  intercept ["newOrder","deleteDelivery","updateStatus","checkQueue","deleteQue"]

  def join("delivery:" <> _restaurentId, %{"position" => position}, socket) do
    send(self(), {:after_join, position})
    {:ok, %{"delivery" => true}, socket}
  end

  def handle_in("newOrder", %{"order" => order}, socket) do
    address = order["address"]
    delivery_id = order["delivery_id"]
    delivery_time = order["delivery_time"]
    name = order["name"]
    number = order["number"]
    order_id = order["order_id"]
    order_time = order["order_time"]
    restaurent_id = order["restaurent_token"]
    staff_id = order["staff_id"]
    status = order["status"]
    gst = order["gst"] / 1
    charge = order["charge"] /1
    restaurentId = order["restaurent_token"]
    orderId = order["order_id"]

    Delivery.addOrder(address, delivery_id, delivery_time, name, number, order_id, order_time, restaurent_id, staff_id, status, gst, charge)
    data = Order.getOrderDetailsById(restaurentId, orderId)
    deliveryData = %{address: address,
                    delivery_id: delivery_id,
                    delivery_time: delivery_time,
                    name: name,
                    number: number,
                    order_id: order_id,
                    order_time: order_time,
                    restaurent_id: restaurent_id,
                    staff_id: staff_id,
                    status: status,
                    data: data,
                    gst: gst,
                    charge: charge
                    }
    broadcast!(socket, "newOrder", deliveryData)
    {:noreply, socket}
  end

  def handle_in("deleteDelivery", %{"delivery" => delivery}, socket) do
    orderId = delivery["order_id"]
    restaurentId = delivery["restaurent_id"]
    staffId = delivery["staffId"]
    deliveryId = delivery["deliveryId"]

    Delivery.deleteDelivery(orderId, restaurentId, staffId, deliveryId)
    broadcast!(socket, "deleteDelivery", %{delivery: delivery})
    {:noreply, socket}
  end

  def handle_in("updateStatus", %{"delivery" => delivery}, socket) do
    orderId = delivery["order_id"]
    restaurent_id = delivery["restaurent_id"]
    deliveryId = delivery["delivery_id"]
    status = delivery["status"]

    Delivery.updateStaus(orderId, restaurent_id, deliveryId, status)
    broadcast!(socket, "updateStatus", %{delivery: delivery})
    {:noreply, socket}
  end

  def handle_info({:after_join, position}, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      latitude: position["latitude"],
      longitude: position["longitude"],
      uToken: position["uToken"]
    })
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("update_position", %{"position" => position}, socket) do
    {:ok, _} = Presence.update(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:second)),
        latitude: position["latitude"],
        longitude: position["longitude"],
        uToken: position["uToken"]
    })

   {:noreply, socket}
 end


  def handle_in("checkQueue", %{"data" => data}, socket) do
    staffId = data["utoken"]
    restaurentId = data["rtoken"]
    section = data["section"]
    task = data["task"]

    queue_data = Queue.getQueue(restaurentId, staffId, section, task)
    count = Enum.count(queue_data)

    cond do
      task == "ADD" ->
        if count !== 0 do
          for i <- 0..count-1, i >= 0 do
            deliveryId =  Enum.at(queue_data, i)
            delivery = Delivery.getdelivery(restaurentId, deliveryId)
            dcount = Enum.count(delivery)
            if dcount !== 0 do
              for d <- 0..dcount-1, d >= 0  do
                order_data = Enum.at(delivery, d)
                data_order = Enum.at(order_data, 7)
                order_id = elem(data_order, 1)
                productDetails = Delivery.getDeliveryDetails(order_id)

                order_details = %{"delivery" => delivery,
                                  "productDetails" => productDetails,
                                   "task" => task,
                                  "staffId" => staffId}

                broadcast!(socket, "checkQueue", %{"order_details" => order_details})
              end
            else
              order_details = %{"delivery" => false,
                                "productDetails" => false,
                                "task" => task,
                                "staffId" => staffId}
              broadcast!(socket, "checkQueue", %{"order_details" => order_details})
            end
          end
        else
          order_details = %{"delivery" => false,
                            "productDetails" => false,
                            "task" => task,
                            "staffId" => staffId}
          broadcast!(socket, "checkQueue", %{"order_details" => order_details})
        end


      task == "UPDATE" ->
        if count !== 0 do
            for i <- 0..count-1, i >= 0 do
                deliveryId =  Enum.at(queue_data, i)
                delivery = Delivery.getdelivery(restaurentId, deliveryId)
                dcount = Enum.count(delivery)
                if dcount !== 0 do
                    order_details = %{"delivery" => delivery,
                                      "productDetails" => false,
                                      "task" => task,
                                      "staffId" => staffId}
                    broadcast!(socket, "checkQueue", %{"order_details" => order_details})
                else
                    order_details = %{"delivery" => false,
                                      "productDetails" => false,
                                      "task" => task,
                                      "staffId" => staffId}
                    broadcast!(socket, "checkQueue", %{"order_details" => order_details})
                end
            end
        else
            order_details = %{"delivery" => false,
                              "productDetails" => false,
                              "task" => task,
                              "staffId" => staffId}
            broadcast!(socket, "checkQueue", %{"order_details" => order_details})
        end


      task == "DELETE" ->
        if count !== 0 do
          for i <- 0..count-1, i >= 0 do
            deliveryId =  Enum.at(queue_data, i)

            order_details = %{"delivery" => deliveryId,
                              "productDetails" => false,
                              "task" => task,
                              "staffId" => staffId}

            broadcast!(socket, "checkQueue", %{"order_details" => order_details})
          end
        else
            order_details = %{"delivery" => false,
                              "productDetails" => false,
                              "task" => task,
                              "staffId" => staffId}

            broadcast!(socket, "checkQueue", %{"order_details" => order_details})
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

    # status = "Success"
    # broadcast!(socket, "deleteQue", %{"status" => status})
    {:noreply, socket}
  end

  def handle_out("newOrder", payload, socket) do

    push(socket, "newOrder", payload)
    {:noreply, socket}
  end

  def handle_out("deleteDelivery", payload, socket) do
    push(socket, "deleteDelivery", payload)
    {:noreply, socket}
  end

  def handle_out("updateStatus", payload, socket) do
    push(socket, "updateStatus",payload)
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

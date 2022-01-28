defmodule PosWeb.ChefChannel do
  use PosWeb, :channel
  alias Pos.Kitchen
  alias Pos.KitchenDetails
  alias PosWeb.Presence
  alias Pos.Queue
  require Logger

  intercept ["order","checkQueue"]

  def join("chef:" <> _restaurentid, %{"userId" => userId}, socket) do
      send(self(), {:after_join, userId})
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("order", %{"order" => order}, socket) do
    kitchenId = order["kitchenId"]
    orderId = order["order_id"]
    restaurentId = order["restaurentId"]
    stafId = order["staffId"]
    date = order["date"]
    note = order["note"]
    time = order["time"]
    status = order["status"]
    productId = order["productId"]
    task = "NEW"
    Kitchen.insertOrderData(date, kitchenId, note, orderId, restaurentId, stafId, status, time)

    count = length(productId)

    for i <- 0..count-1, i >= 0 do
      product = Enum.at(order["productId"] |> List.flatten(), i)
      pId = product["id"]
      quantity = product["quantity"]
      name = product["name"]
      kitchen_details = product["kitchen_details"]

      KitchenDetails.insertKitchenDetails(kitchenId, pId, quantity, restaurentId, name, kitchen_details, task, stafId)
    end


    broadcast!(socket, "order", %{order: order,
                                  stafId: stafId,
                                  kitchenId: kitchenId,
                                  type: "newOrder"
                                })
    {:noreply, socket}
  end

  def handle_in("addProduct", %{"order" => order}, socket) do
    kitchenId = order["kitchenId"]
    restaurentId = order["restaurentId"]
    productId = order["productId"]
    stafId = order["staffId"]
    task = "ADD"

    count = length(productId)
    for i <- 0..count-1, i >= 0  do
      product = Enum.at(order["productId"] |> List.flatten(), i)
      pId = product["id"]
      quantity = product["quantity"]
      name = product["name"]
      kitchen_details = product["kitchen_details"]

      KitchenDetails.insertKitchenDetails(kitchenId, pId, quantity, restaurentId, name, kitchen_details, task, stafId)
    end

    broadcast!(socket, "order", %{order: order,
                                  stafId: stafId,
                                  kitchenId: kitchenId,
                                  type: "addProduct"
                                })
    {:noreply, socket}
  end

  def handle_in("deleteProduct", %{"order" => order}, socket) do
    kitchenId = order["kitchenId"]
    restaurentId = order["restaurentId"]
    productId = order["productId"]
    stafId = order["staffId"]
    kitchen_details = order["kitchen_details"]
    KitchenDetails.deleteProduct(kitchenId, restaurentId, stafId, kitchen_details)

    broadcast!(socket, "order", %{order: order,
                                  stafId: stafId,
                                  kitchenId: kitchenId,
                                  productId: productId,
                                  kitchen_details: kitchen_details,
                                  type: "deleteProduct"
                                })
    {:noreply, socket}
 end

  def handle_in("updateStatus", %{"order" => order}, socket) do
    kitchenId = order["kitchenId"]
    restaurentId = order["restaurentId"]
    status = order["status"]
    stafId = order["staffId"]
    Kitchen.updateStatus(kitchenId,restaurentId, status)

    broadcast!(socket, "order", %{kitchenId: kitchenId,
                                  stafId: stafId,
                                  type: "updateStatus",
                                  status: status
                                })
    {:noreply, socket}
  end

  def handle_info({:after_join, userId}, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      userId: userId,
    })

    push(socket, "presence_state", Presence.list(socket))
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
      task == "ADD" and section == "Kitchen" ->
          if count !== 0 do
              for i <- 0..count-1, i >= 0 do
                kitchenId =  Enum.at(queue_data, i)
                kitchen = Kitchen.getKitchenData(restaurentId, kitchenId)
                kitchen_details = KitchenDetails.getKitchenDetails(kitchenId, restaurentId)
                kichen_data = %{"task" => task,
                                "staffId" => staffId,
                                "kitchen" => kitchen,
                                "kitchen_details" => kitchen_details,
                                "section" => section}
                broadcast!(socket, "checkQueue", %{"data" => kichen_data})
              end
          else
              kichen_data = %{"task" => task,
                              "staffId" => staffId,
                              "kitchen" => false,
                              "kitchen_details" => false,
                              "section" => section}

              broadcast!(socket, "checkQueue", %{"data" => kichen_data})
          end

      task == "ADD" and section == "kitchen_details" ->
          if count !== 0 do
              for i <- 0..count-1, i >= 0 do
                  kitchen_details =  Enum.at(queue_data, i)
                  kitchen_details_data = KitchenDetails.getKitchenDetailsByKitchennDetails(restaurentId, kitchen_details)
                  kcount = Enum.count(kitchen_details_data)
                  if kcount !== 0 do
                        # if i == 0 do
                          kitchen_data = Enum.at(kitchen_details_data, 0)
                          data_kitchen = Enum.at(kitchen_data, 1)
                          kitchenId = elem(data_kitchen, 1)
                          kitchen = Kitchen.getKitchenData(restaurentId, kitchenId)
                          kichen_data = %{"task" => task,
                                          "staffId" => staffId,
                                          "kitchen" => kitchen,
                                          "kitchen_details" => kitchen_details_data,
                                          "section" => section}

                          broadcast!(socket, "checkQueue", %{"data" => kichen_data})
                        # end
                  else
                    kichen_data = %{"task" => task,
                                    "staffId" => staffId,
                                    "kitchen" => false,
                                    "kitchen_details" => false,
                                    "section" => section}

                    broadcast!(socket, "checkQueue", %{"data" => kichen_data})
                  end
              end
          else
              kichen_data = %{"task" => task,
                              "staffId" => staffId,
                              "kitchen" => false,
                              "kitchen_details" => false,
                              "section" => section}

              broadcast!(socket, "checkQueue", %{"data" => kichen_data})
          end
      task == "DELETE" and section == "kitchen_details" ->
        if count !== 0 do
          for i <- 0..count-1, i >= 0 do
            kitchen_details =  Enum.at(queue_data, i)
            kichen_data = %{"task" => task,
                            "staffId" => staffId,
                            "kitchen" => false,
                            "kitchen_details" => kitchen_details,
                            "section" => section}

            broadcast!(socket, "checkQueue", %{"data" => kichen_data})
          end
        else
          kichen_data = %{"task" => task,
                          "staffId" => staffId,
                          "kitchen" => false,
                          "kitchen_details" => false,
                          "section" => section}

          broadcast!(socket, "checkQueue", %{"data" => kichen_data})
        end
      task == "UPDATE" ->
        if count !== 0 do
          for i <- 0..count-1, i >= 0 do
            kitchenId =  Enum.at(queue_data, i)
            kitchen = Kitchen.getKitchenData(restaurentId, kitchenId)
            kcount = Enum.count(kitchen)
            if kcount !== 0 do
              kichen_data = %{"task" => task,
                            "staffId" => staffId,
                            "kitchen" => kitchen,
                            "kitchen_details" => false,
                            "section" => section}
              broadcast!(socket, "checkQueue", %{"data" => kichen_data})
            else
              kichen_data = %{"task" => task,
                          "staffId" => staffId,
                          "kitchen" => false,
                          "kitchen_details" => false,
                          "section" => section}
              broadcast!(socket, "checkQueue", %{"data" => kichen_data})
            end
          end
        else
          kichen_data = %{"task" => task,
                          "staffId" => staffId,
                          "kitchen" => false,
                          "kitchen_details" => false,
                          "section" => section}
          broadcast!(socket, "checkQueue", %{"data" => kichen_data})
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

  def handle_out("order", payload, socket) do
    push(socket, "order", payload)
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

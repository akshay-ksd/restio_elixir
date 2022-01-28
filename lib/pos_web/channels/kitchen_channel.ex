defmodule PosWeb.KitchenChannel do
  use PosWeb, :channel
  alias Pos.Kitchen
  alias Pos.KitchenDetails
  alias PosWeb.Presence

  intercept ["addOrder","addProduct"]

  def join("Kitchen:" <> _restaurentId, _params, socket) do
      send(self(), :after_join)
      {:ok, %{"status" => true}, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      uToken: socket.assigns.user_id,
      stafId: "0",
      order: false,
      kitchenId: "0",
      type: "join"
    })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("newOrder", %{"order" => order}, socket) do
    kitchenId = order["kitchenId"]
    orderId = order["order_id"]
    restaurentId = order["restaurentId"]
    stafId = order["staffId"]
    date = order["date"]
    note = order["note"]
    time = order["time"]
    status = order["status"]
    productId = order["productId"]

    Kitchen.insertOrderData(date, kitchenId, note, orderId, restaurentId, stafId, status, time)

    count = length(productId)

    for i <- 0..count-1, i >= 0 do
      product = Enum.at(order["productId"] |> List.flatten(), i)
      pId = product["id"]
      quantity = product["quantity"]
      name = product["name"]

      KitchenDetails.insertKitchenDetails(kitchenId, pId, quantity, restaurentId, name)
    end

    {:ok, _} = Presence.update(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      uToken: socket.assigns.user_id,
      order: order,
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

    count = length(productId)

    for i <- 0..count-1, i >= 0  do
      product = Enum.at(order["productId"] |> List.flatten(), i)
      pId = product["id"]
      quantity = product["quantity"]
      name = product["name"]

      KitchenDetails.insertKitchenDetails(kitchenId, pId, quantity, restaurentId, name)
    end

    {:ok, _} = Presence.update(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      uToken: socket.assigns.user_id,
      order: order,
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

    KitchenDetails.deleteProduct(kitchenId, productId, restaurentId)

    {:ok, _} = Presence.update(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      uToken: socket.assigns.user_id,
      order: order,
      stafId: stafId,
      kitchenId: kitchenId,
      productId: productId,
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

    {:ok, _} = Presence.update(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second)),
      uToken: socket.assigns.user_id,
      kitchenId: kitchenId,
      stafId: stafId,
      type: "updateStatus",
      status: status
    })

    {:noreply, socket}
 end
end

defmodule PosWeb.DownloadData.DeliveryChannel do
  use PosWeb, :channel
  intercept ["getData"]
  alias Pos.Delivery
  alias Pos.Queue
  alias Pos.Order

  def join("deliveryData:" <> _restaurentid, %{"data" => data}, socket) do
    restaurentId = data["rtoken"]
    staffId = data["utoken"]
    Queue.deleteQueByStaffId(restaurentId, staffId)
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("getData", %{"data" => data}, socket) do
    restaurentId = data["rtoken"]
    userId = data["utoken"]
    section = data["section"]
    # access = data["access"]

    delivery_data = Delivery.getDeliveryDataByStaffId(restaurentId,userId)
    count = Enum.count(delivery_data)
    if count !== 0 do
        for i <- 0..count-1, i >= 0 do

          order_details = Enum.at(delivery_data, i)
          details_order = Enum.at(order_details, 7)
          orderId = elem(details_order, 1)

          productDetails = Order.getOrderDetailsById(restaurentId, orderId)

          deliveryData = %{ "order_details" => order_details,
                            "productDetails" => productDetails,
                            }

            s_data = %{"data" => deliveryData,"section" => section}
            broadcast!(socket, "getData", %{"data" => s_data})

          if i == count-1 do
            s_data = %{"data" => false,"section" => section}
            broadcast!(socket, "getData", %{"data" => s_data})
          end
        end
    else
        s_data = %{"data" => false,"section" => section}
        broadcast!(socket, "getData", %{"data" => s_data})
    end
    {:noreply, socket}
  end

  def handle_out("getData", payload, socket) do
    push(socket, "getData", payload)
    {:noreply, socket}
  end
end

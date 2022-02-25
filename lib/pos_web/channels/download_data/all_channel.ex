defmodule PosWeb.DownloadData.AllChannel  do
  use PosWeb, :channel
  intercept ["getData"]
  alias Pos.Staff
  alias Pos.Category
  alias Pos.Product
  alias Pos.OrderMaster
  alias Pos.Order
  alias Pos.Delivery
  alias Pos.Kitchen
  alias Pos.KitchenDetails
  alias Pos.Expence
  alias Pos.Queue
  alias Pos.StaffAttendence
  require Logger

  def join("all:" <> _restaurentid, %{"data" => data}, socket) do
    restaurentId = data["rtoken"]
    staffId = data["utoken"]
    Queue.deleteQueByStaffId(restaurentId, staffId)
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("getData", %{"data" => data}, socket) do
    restaurentId = data["rtoken"]
    # userId = data["utoken"]
    section = data["section"]
    # access = data["access"]

    cond do
        section == "Staff" ->
            staff_data = Staff.getStaffDataByRestaurenToken(restaurentId)
            count = Enum.count(staff_data)

            if count !== 0 do
                s_data = %{"data" => staff_data,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end

        section == "Menu" ->
            menu_data = Category.getCategoryByRestaurentId(restaurentId)
            count = Enum.count(menu_data)

            if count !== 0 do
                s_data = %{"data" => menu_data,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end

        section == "Product" ->
            product_data = Product.getProductByRestaurenId(restaurentId)
            count = Enum.count(product_data)

            if count !== 0 do
                s_data = %{"data" => product_data,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end

        section == "OrderMaster" ->
            order_master_data = OrderMaster.getOrderDataByRestaurentId(restaurentId)
            count = Enum.count(order_master_data)

            if count !== 0 do
                for o <- 0..count-1, o >= 0  do
                    order_data = Enum.at(order_master_data, o)
                    data_order = Enum.at(order_data, 3)
                    orderId = elem(data_order, 1)
                    Logger.info orderId
                end
                s_data = %{"data" => order_master_data,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end

        section == "Order" ->
            order_data = Order.getOrderDetailsByRestaurentId(restaurentId)
            count = Enum.count(order_data)

            if count !== 0 do
                s_data = %{"data" => order_data,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end

        section == "Delivery" ->
            delivery_data = Delivery.getDeliveryDataByRestaurentId(restaurentId)
            count = Enum.count(delivery_data)

            if count !== 0 do
                s_data = %{"data" => delivery_data,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end

        section == "Kitchen" ->
            kitchen_data = Kitchen.getKichenDataByRestaurentId(restaurentId)
            count = Enum.count(kitchen_data)

            if count !== 0 do
                s_data = %{"data" => kitchen_data,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end

        section == "KitchenDetails" ->
            kitchen_details = KitchenDetails.getKitchenDetailsByRestaurentId(restaurentId)
            count = Enum.count(kitchen_details)

            if count !== 0 do
                s_data = %{"data" => kitchen_details,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end

        section == "Expence" ->
            expence = Expence.getExpenceByRestaurentId(restaurentId)
            count = Enum.count(expence)

            if count !== 0 do
                s_data = %{"data" => expence,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end
        section == "Attendence" ->
            attendence = StaffAttendence.getAttendenceByRestaurentId(restaurentId)
            count = Enum.count(attendence)

            if count !== 0 do
                s_data = %{"data" => attendence,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            else
                s_data = %{"data" => false,"section" => section}
                broadcast!(socket, "getData", %{"data" => s_data})
            end

    end

    {:noreply, socket}
  end

  def handle_out("getData", payload, socket) do
    push(socket, "getData", payload)
    {:noreply, socket}
  end
end

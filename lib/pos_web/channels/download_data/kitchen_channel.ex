defmodule PosWeb.DownloadData.KitchenChannel do
  use PosWeb, :channel
  alias Pos.Kitchen
  alias Pos.KitchenDetails
  alias Pos.Queue
  intercept ["getData"]

  def join("kichenData:"  <> _restaurentid, %{"data" => data}, socket) do
    restaurentId = data["rtoken"]
    staffId = data["utoken"]
    Queue.deleteQueByStaffId(restaurentId, staffId)
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("getData", %{"data" => data}, socket) do
    restaurentId = data["rtoken"]
    section = data["section"]

    cond do
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
    end

    {:noreply, socket}
  end

  def handle_out("getData", payload, socket) do
    push(socket, "getData", payload)
    {:noreply, socket}
  end
end

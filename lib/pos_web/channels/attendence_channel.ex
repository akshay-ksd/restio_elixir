defmodule PosWeb.AttendenceChannel do
  use PosWeb, :channel
  alias Pos.StaffAttendence
  intercept  ["add"]

  def join("attendence:" <> _restaurentid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("add", %{"data" => data}, socket) do
    staffData = data["staffData"]

    count = length(staffData)
    for i <- 0..count-1, i >= 0 do
      attendenceData = Enum.at(data["staffData"] |> List.flatten(), i)

      date = DateTime.utc_now()
      name = attendenceData["name"]
      present = attendenceData["present"]
      restaurentId = attendenceData["restaurentId"]
      staffId = attendenceData["staffId"]

      StaffAttendence.addAttendence(date,name,present,restaurentId,staffId)
    end

    broadcast!(socket, "add", %{"data" => data})
    {:noreply, socket}
  end

  def handle_out("add", payload, socket) do
    push(socket, "add", payload)
    {:noreply, socket}
  end
end

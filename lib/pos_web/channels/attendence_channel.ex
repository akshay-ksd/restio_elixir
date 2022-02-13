defmodule PosWeb.AttendenceChannel do
  use PosWeb, :channel
  alias Pos.StaffAttendence
  intercept  ["add"]
  require Logger

  def join("attendence:" <> _restaurentid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("add", %{"data" => data}, socket) do
    staffData = data["staffData"]

    count = length(staffData)
    for i <- 0..count-1, i >= 0 do
      attendenceData = Enum.at(data["staffData"] |> List.flatten(), i)
      date = DateTime.utc_now()
      Logger.info date
      # date = attendenceData["date"]
      name = attendenceData["name"]
      present = attendenceData["present"]
      restaurentId = attendenceData["restaurentId"]
      staffId = attendenceData["staffId"]
      attendenceId = attendenceData["attendenceId"]

      if present == true do
          with {:ok, staff_attendence} <- StaffAttendence.addAttendence(date,name,present,restaurentId,staffId) do
              broadcast_data = %{
                  "attendence_id" => staff_attendence.id,
                  "name" => staff_attendence.name,
                  "present" => staff_attendence.present,
                  "staffId" => staff_attendence.staffId,
                  "date" => staff_attendence.date
              }
              broadcast!(socket, "add", %{"data" => broadcast_data})
          end
      else
          StaffAttendence.deleteAttendence(attendenceId)

          broadcast_data = %{
              "attendence_id" => attendenceId,
              "name" => name,
              "present" => present,
              "staffId" => staffId,
              "date" => date
          }
          broadcast!(socket, "add", %{"data" => broadcast_data})
      end

    end
    {:noreply, socket}
  end

  def handle_out("add", payload, socket) do
    push(socket, "add", payload)
    {:noreply, socket}
  end
end

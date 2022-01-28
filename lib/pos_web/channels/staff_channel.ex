defmodule PosWeb.StaffChannel do
  use PosWeb, :channel
  alias Pos.Staff
  alias Pos.Queue
  alias Pos.Restaurent
  require Logger

  intercept ["addStaff","updateStaff","checkQueue","getRestDetails"]

  def join("staff:" <> _restaurentid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("addStaff", %{"staff" => staff}, socket) do
    access = staff["access"]
    uname = staff["name"]
    number = staff["number"]
    password = staff["password"]
    restaurent_token = staff["restaurent_token"]
    u_token = staff["token"]
    is_active = staff["is_active"]

    Staff.add_staff(access, uname, number, password, restaurent_token, u_token, is_active)
    broadcast!(socket, "addStaff", %{staff: staff})
    {:noreply, socket}
  end

  def handle_in("updateStaff", %{"staff" => staff}, socket) do
    access = staff["access"]
    uname = staff["name"]
    number = staff["number"]
    password = staff["password"]
    restaurent_token = staff["restaurent_token"]
    u_token = staff["token"]
    is_active = staff["is_active"]

    Staff.update_staff(access, uname, number, password, restaurent_token, u_token, is_active)

    broadcast!(socket, "updateStaff", %{staff: staff})
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
        for i <- 0..count-1, i >= 0 do
            token =  Enum.at(queue_data, i)
            staff_details = Staff.getStaffDataByQueId(token, restaurentId)
            scount = Enum.count(staff_details)
            if scount !== 0 do
              staff_data = %{"staff_data" => staff_details,
                          "task" => task,
                          "staffId" => staffId,
                          "section" => section}
              broadcast!(socket, "checkQueue", %{"data" => staff_data})
            else
              staff_data = %{"staff_data" => false,
                            "task" => task,
                            "staffId" => staffId,
                            "section" => section}
              broadcast!(socket, "checkQueue", %{"data" => staff_data})
            end
        end
    else
        staff_data = %{"staff_data" => false,
                       "task" => task,
                       "staffId" => staffId,
                       "section" => section}
        broadcast!(socket, "checkQueue", %{"data" => staff_data})
    end
    {:noreply, socket}
  end

  def handle_in("deleteQue", %{"data" => data}, socket) do
    staffId = data["uToken"]
    restaurentId = data["rToken"]
    accessid = data["accessid"]
    task = data["task"]

    Queue.deleteQue(restaurentId, staffId, accessid, task)
    {:noreply, socket}
  end

  def handle_in("getRestDetails", %{"data" => data}, socket) do
    token = data["rtoken"]

    restaurent = Restaurent.getRestaurentDataByToken(token)
    broadcast!(socket, "getRestDetails", %{"data" => restaurent})
    {:noreply, socket}
 end


  def handle_out("addStaff", payload, socket) do
    push(socket, "addStaff", payload)
    {:noreply, socket}
  end

  def handle_out("updateStaff", payload, socket) do
    push(socket, "updateStaff", payload)
    {:noreply, socket}
  end

  def handle_out("checkQueue", payload, socket) do
    push(socket, "checkQueue", payload)
    {:noreply, socket}
  end

  def handle_out("getRestDetails", payload, socket) do
    push(socket, "getRestDetails", payload)
    {:noreply, socket}
  end
end

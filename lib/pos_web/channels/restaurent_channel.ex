defmodule PosWeb.RestaurentChannel do
  use PosWeb, :channel
  alias Pos.Restaurent
  alias Pos.Staff
  intercept ["addRest","updateRest","getRestaurent"]
  def join("restaurent:" <> _restaurentid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("addRest", %{"data" => data}, socket) do
    name = data["name"]
    number = data["number"]
    email_id = data["email_id"]
    latitude = data["latitude"]
    longitude = data["longitude"]
    image_url = data["image_url"]
    token = data["token"]
    address = data["address"]

    access = "ALL"
    uname = "Admin"
    password = number
    restaurent_token = token
    u_token = token
    is_active = true

    Restaurent.register(address, email_id, image_url, latitude, longitude, name, number, token)
    Staff.add_staff(access, uname, number, password, restaurent_token, u_token, is_active)

    broadcast!(socket, "addRest", %{"data" => data})
    {:noreply, socket}
  end

  def handle_in("updateRest", %{"data" => data}, socket) do
    name = data["name"]
    number = data["number"]
    token = data["token"]
    address = data["address"]

    Restaurent.updateRestaurent(token, name, number, address)

    broadcast!(socket, "updateRest", %{"data" => data})
    {:noreply, socket}
  end

  def handle_in("updateCharges", %{"data" => data}, socket) do
    token = data["token"]
    gst = data["gst"]
    charge = data["charge"]
    s_gst = data["s_gst"]

    Restaurent.updateCharges(charge,gst,token,s_gst)
    broadcast!(socket, "updateCharges", %{"data" => data})
    {:noreply, socket}
  end

  def handle_in("getRestaurent", %{"data" => data}, socket) do
    offset = data["offset"]
    limit = data["limit"]
    restData = Restaurent.getRestaurent(offset, limit)
    broadcast!(socket, "getRestaurent", %{"restData" => restData})
    {:noreply, socket}
  end

  def handle_out("addRest", payload, socket) do
    push(socket, "addRest", payload)
    {:noreply, socket}
  end

  def handle_out("updateRest", payload, socket) do
    push(socket, "updateRest", payload)
    {:noreply, socket}
  end

  def handle_out("updateCharges", payload, socket) do
    push(socket, "updateCharges", payload)
    {:noreply, socket}
  end

  def handle_out("getRestaurent", payload, socket) do
    push(socket, "getRestaurent", payload)
    {:noreply, socket}
  end
end

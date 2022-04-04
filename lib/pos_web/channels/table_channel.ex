defmodule PosWeb.TableChannel do
  use PosWeb, :channel
  alias Pos.Table

  intercept ["addTable","getTabledetails"]

  def join("table:" <> _restaurentid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("addTable", %{"data" => data}, socket) do

    restaurentId = data["restaurentId"]
    name = data["name"]

    Table.addTableDetails(restaurentId, name)

    broadcast!(socket, "addTable", %{"data" => data})
    {:reply, :ok, socket}
  end

  def handle_in("getTabledetails", %{"data" => data}, socket) do
    restaurentId = data["restaurentId"]

    tableDetails = Table.getTableDetailsByRestaurentId(restaurentId)

    broadcast!(socket, "getTabledetails", %{"tableDetails" => tableDetails})
  end

  def handle_out("addTable", payload, socket) do
    push(socket, "addTable", payload)
    {:noreply, socket}
  end

  def handle_out("getTabledetails", payload, socket) do
    push(socket, "getTabledetails", payload)
    {:noreply, socket}
  end
end

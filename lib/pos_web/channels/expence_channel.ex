defmodule PosWeb.ExpenceChannel do
  use PosWeb, :channel
  alias Pos.Expence
  alias Pos.Queue
  alias Pos.OrderMaster

  intercept ["addExpence","updateExpence","deleteExpence","checkQueue","get_report"]

  def join("expence:" <> _restaurentid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("addExpence", %{"expence" => expence}, socket) do
    restaurentId = expence["restaurentId"]
    paymentType = expence["paymentType"]
    category = expence["category"]
    amount = expence["amount"]
    date = expence["date"]
    month = expence["month"]
    year = expence["year"]
    expenceId = expence["expenceId"]

    Expence.addExpence(restaurentId,paymentType,category,amount,date,month,year,expenceId)

    broadcast!(socket, "addExpence", %{expence: expence})
    {:noreply, socket}
  end

  def handle_in("updateExpence", %{"expence" => expence}, socket) do
    expenceId = expence["expenceId"]
    restaurentId = expence["restaurentId"]
    paymentType = expence["paymentType"]
    category = expence["category"]
    amount = expence["amount"]

    Expence.updateExpence(restaurentId, paymentType, category, amount, expenceId)

    broadcast!(socket, "updateExpence", %{expence: expence})
    {:noreply, socket}
  end

  def handle_in("deleteExpence", %{"expence" => expence}, socket) do
    expenceId = expence["expenceId"]
    restaurentId = expence["restaurentId"]

    Expence.deleteExpence(restaurentId,expenceId)

    broadcast!(socket, "deleteExpence", %{expence: expence})
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
                expenceId =  Enum.at(queue_data, i)
            if task !== "DELETE" do
                expence = Expence.getExpenceById(restaurentId, expenceId)
                scount = Enum.count(expence)
                if scount !== 0 do
                  staff_data = %{"expence" => expence,
                                "task" => task,
                                "staffId" => staffId,
                                "section" => section}
                  broadcast!(socket, "checkQueue", %{"data" => staff_data})
                else
                  staff_data = %{"expence" => false,
                                 "task" => task,
                                 "staffId" => staffId,
                                 "section" => section}
                  broadcast!(socket, "checkQueue", %{"data" => staff_data})
                end
            else
                staff_data = %{"expence" => expenceId,
                               "task" => task,
                               "staffId" => staffId,
                               "section" => section}
                broadcast!(socket, "checkQueue", %{"data" => staff_data})
            end
          end
        else
            staff_data = %{"expence" => false,
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

  def handle_in("get_report", %{"data" => data}, socket) do
    restaurentId = data["rToken"]
    date = data["date"]

    orderData = OrderMaster.getOrderByDate(restaurentId,date)
    expenceData = Expence.getExpenceBydate(restaurentId, date)

    data = %{"orderData" => orderData,"expenceData" => expenceData}
    broadcast!(socket, "get_report", %{data: data})
    {:noreply, socket}
  end

  def handle_out("addExpence", payload, socket) do
    push(socket, "addExpence", payload)
    {:noreply, socket}
  end

  def handle_out("updateExpence", payload, socket) do
    push(socket, "updateExpence", payload)
    {:noreply, socket}
  end

  def handle_out("deleteExpence", payload, socket) do
    push(socket, "deleteExpence", payload)
    {:noreply, socket}
  end

  def handle_out("checkQueue", payload, socket) do
    push(socket, "checkQueue", payload)
    {:noreply, socket}
  end

  def handle_out("get_report", payload, socket) do
    push(socket, "get_report", payload)
    {:noreply, socket}
  end
end

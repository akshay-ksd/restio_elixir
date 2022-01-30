defmodule PosWeb.PlanChannel do
  use PosWeb, :channel
  alias Pos.Plans
  alias Pos.RechargeDetails
  alias Pos.Bill
  alias Pos.Staff
  require Logger

  intercept ["addPlan","recharge","currentPlan"]

  def join("plan:" <> _admin_id, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("addPlan", %{"data" => data}, socket) do

    days = data["days"]
    name = data["name"]
    plan_id = data["plan_id"]
    price = data["price"]

    Plans.addPlan(days, name, plan_id, price)

    broadcast!(socket, "addPlan", %{"data" => data})
    {:noreply, socket}
  end

  def handle_in("recharge", %{"data" => data}, socket) do
    date = DateTime.utc_now()
    plan_id = data["planId"]
    plandata = Plans.getPlanById(plan_id)

    days = plandata.days

    valid = Date.utc_today
    expaired = Date.add(valid, days)

    expaired = expaired
    rechargeId = data["rechargeId"]
    restaurentId = data["restaurentId"]
    valid = valid
    salesExicutiveId = data["exicutiveId"]

    {:ok, status} = RechargeDetails.addRechargeDetails(expaired, plan_id, rechargeId, restaurentId, valid)
    Bill.addBillDetails(rechargeId, date, plan_id, restaurentId, salesExicutiveId)

    broadcast!(socket, "recharge", %{"rechargeId" => rechargeId,
                                     "restaurentId" => restaurentId,
                                     "status" => status})
    {:noreply, socket}
  end

  def handle_in("currentPlan", %{"data" => data}, socket) do
    restaurentId = data["restaurentId"]
    date = Date.utc_today
    token = data["active_token"]
    utoken = data["utoken"]

    rechargedata = RechargeDetails.getCurrentPlan(restaurentId,date)

    {:ok, user} = Staff.get_id_by_token(token)

    if rechargedata == nil do
      if user == false do
        broadcast!(socket, "currentPlan", %{"status" => false, "authentication" => false, "token" => utoken, "active_token" => token})
      else
        broadcast!(socket, "currentPlan", %{"status" => false, "authentication" => true, "token" => utoken, "active_token" => token})
      end
    else
      if user == false do
        broadcast!(socket, "currentPlan", %{"status" => true,
                                            "data" => rechargedata, "authentication" => false, "token" => utoken, "active_token" => token})
      else
        broadcast!(socket, "currentPlan", %{"status" => true,
                                            "data" => rechargedata, "authentication" => true, "token" => utoken, "active_token" => token})
      end
    end
    {:noreply, socket}

  end



  def handle_out("addPlan", payload, socket) do
    push(socket, "addPlan", payload)
    {:noreply, socket}
  end

  def handle_out("recharge", payload, socket) do
    push(socket, "recharge", payload)
    {:noreply, socket}
  end

  def handle_out("currentPlan", payload, socket) do
    push(socket, "currentPlan", payload)
    {:noreply, socket}
  end
end

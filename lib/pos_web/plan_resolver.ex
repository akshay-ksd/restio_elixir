defmodule PosWeb.PlanResolver do
  alias Pos.Plans
  require Logger
 def all_plans(_root, _args, _info) do
  {:ok,Plans.getPlanDetails()}
 end

end

defmodule PosWeb.Schema do
  use Absinthe.Schema

  object :plans do
    field :plan_id, non_null(:string)
    field :name, non_null(:string)
    field :days, non_null(:integer)
    field :price, non_null(:integer)
  end

  object :plan_data do
    field :expaired, non_null(:string)
    field :planId, non_null(:string)
    field :rechargeId, non_null(:string)
    field :restaurentId, non_null(:string)
    field :time, non_null(:string)
    field :valid, non_null(:string)

  end

  query do
    @desc "Get All Plans"
    field :all_plans, non_null(list_of(non_null(:plans))) do
      resolve(&PosWeb.PlanResolver.all_plans/3)
    end
  end

end

defmodule Pos.Repo.Migrations.OrderMasterGstChargeModify do
  use Ecto.Migration

  def change do
    alter table("order_master") do
      modify :gst, :integer
      modify :charge, :integer
    end
  end
end

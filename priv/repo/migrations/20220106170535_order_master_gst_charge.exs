defmodule Pos.Repo.Migrations.OrderMasterGstCharge do
  use Ecto.Migration

  def change do
    alter table("order_master") do
      add :gst, :numeric
      add :charge, :numeric
    end
  end
end

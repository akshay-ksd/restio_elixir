defmodule Pos.Repo.Migrations.DeliveryGstCharge do
  use Ecto.Migration

  def change do
    alter table("delivery") do
      add :gst, :integer
      add :charge, :integer
    end
  end
end

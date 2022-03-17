defmodule Pos.Repo.Migrations.RestaurentGstModify do
  use Ecto.Migration

  def change do
    alter table("restaurent") do
      add :s_gst, :numeric
    end
    alter table("order_master") do
      add :s_gst, :numeric
    end
    alter table("delivery") do
      add :s_gst, :numeric
    end
  end
end

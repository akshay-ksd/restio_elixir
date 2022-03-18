defmodule Pos.Repo.Migrations.Cgst do
  use Ecto.Migration

  def change do
    alter table("order_master") do
      add :c_gst, :numeric
    end
    alter table("delivery") do
      add :c_gst, :numeric
    end
  end
end

defmodule Pos.Repo.Migrations.OrderMasterDate do
  use Ecto.Migration

  def change do
    alter table("order_master") do
      add :order_date, :utc_datetime_usec
    end
  end
end

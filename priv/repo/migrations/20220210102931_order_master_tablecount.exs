defmodule Pos.Repo.Migrations.OrderMasterTablecount do
  use Ecto.Migration

  def change do
    alter table("order_master") do
      add :tableNumber, :integer
    end
  end
end

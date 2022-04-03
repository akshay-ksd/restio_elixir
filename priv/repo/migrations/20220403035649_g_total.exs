defmodule Pos.Repo.Migrations.GTotal do
  use Ecto.Migration

  def change do
    alter table("order_master") do
      add :gTotal, :text
      add :date_order, :date
    end
  end
end

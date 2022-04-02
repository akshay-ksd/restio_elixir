defmodule Pos.Repo.Migrations.Total do
  use Ecto.Migration

  def change do
    alter table("order_master") do
      add :total, :numeric
    end
  end
end

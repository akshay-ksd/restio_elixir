defmodule Pos.Repo.Migrations.Day do
  use Ecto.Migration

  def change do
    alter table("order_master") do
      add :year, :integer
      add :month, :integer
      add :day, :integer
    end
  end
end

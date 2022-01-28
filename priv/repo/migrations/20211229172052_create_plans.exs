defmodule Pos.Repo.Migrations.CreatePlans do
  use Ecto.Migration

  def change do
    create table(:plans) do
      add :plan_id, :text
      add :name, :text
      add :days, :integer
      add :price, :integer

      timestamps()
    end

  end
end

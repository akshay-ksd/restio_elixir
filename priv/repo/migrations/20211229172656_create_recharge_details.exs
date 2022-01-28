defmodule Pos.Repo.Migrations.CreateRechargeDetails do
  use Ecto.Migration

  def change do
    create table(:recharge_details) do
      add :rechargeId, :text
      add :restaurentId, :text
      add :planId, :text
      add :valid, :date
      add :expaired, :date
      add :time, :time

      timestamps()
    end

  end
end

defmodule Pos.Repo.Migrations.CreateBill do
  use Ecto.Migration

  def change do
    create table(:bill) do
      add :billId, :text
      add :restaurentId, :text
      add :planId, :text
      add :salesExicutiveId, :text
      add :date, :utc_datetime

      timestamps()
    end

  end
end

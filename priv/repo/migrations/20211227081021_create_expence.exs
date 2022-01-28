defmodule Pos.Repo.Migrations.CreateExpence do
  use Ecto.Migration

  def change do
    create table(:expence) do
      add :restaurentId, :text
      add :amount, :integer
      add :category, :text
      add :paymentType, :integer

      timestamps()
    end

  end
end

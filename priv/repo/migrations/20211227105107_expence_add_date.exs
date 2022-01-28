defmodule Pos.Repo.Migrations.ExpenceAddDate do
  use Ecto.Migration

  def change do
    alter table("expence") do
      add :date, :string
      add :month, :integer
      add :year, :integer
    end
  end
end

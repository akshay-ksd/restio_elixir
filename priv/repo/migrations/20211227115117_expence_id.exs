defmodule Pos.Repo.Migrations.ExpenceId do
  use Ecto.Migration

  def change do
    alter table("expence") do
      add :expenceId, :text
    end
  end
end

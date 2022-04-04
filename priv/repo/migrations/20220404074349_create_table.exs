defmodule Pos.Repo.Migrations.CreateTable do
  use Ecto.Migration

  def change do
    create table(:table) do
      add :restaurentId, :text
      add :name, :text

      timestamps()
    end

  end
end

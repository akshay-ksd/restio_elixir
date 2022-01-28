defmodule Pos.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:category) do
      add :category_id, :text
      add :categoryName, :text
      add :restaurent_id, :text

      timestamps()
    end

  end
end

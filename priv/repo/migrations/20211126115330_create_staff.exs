defmodule Pos.Repo.Migrations.CreateStaff do
  use Ecto.Migration

  def change do
    create table(:staff) do
      add :name, :text
      add :number, :text
      add :password, :text
      add :restaurent_token, :text
      add :token, :text
      add :access, :string

      timestamps()
    end

  end
end

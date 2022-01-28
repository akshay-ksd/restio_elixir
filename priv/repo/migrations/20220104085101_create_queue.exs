defmodule Pos.Repo.Migrations.CreateQueue do
  use Ecto.Migration

  def change do
    create table(:queue) do
      add :restaurentId, :text
      add :staffId, :text
      add :section, :text
      add :accessid, :text
      add :task, :string
      add :time, :utc_datetime_usec

      timestamps()
    end

  end
end

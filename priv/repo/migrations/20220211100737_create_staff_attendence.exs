defmodule Pos.Repo.Migrations.CreateStaffAttendence do
  use Ecto.Migration

  def change do
    create table(:staff_attendence) do
      add :staffId, :text
      add :date, :utc_datetime_usec
      add :name, :text
      add :restaurentId, :text
      add :present, :boolean, default: false, null: false

      timestamps()
    end

  end
end

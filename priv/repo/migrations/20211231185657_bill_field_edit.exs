defmodule Pos.Repo.Migrations.BillFieldEdit do
  use Ecto.Migration

  def change do
    alter table("bill") do
      modify :date, :utc_datetime_usec
    end
  end
end

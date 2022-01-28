defmodule Pos.Repo.Migrations.RestaurentsCharges do
  use Ecto.Migration

  def change do
    alter table("restaurent") do
      add :charge, :integer
      add :gst, :integer
    end
  end
end

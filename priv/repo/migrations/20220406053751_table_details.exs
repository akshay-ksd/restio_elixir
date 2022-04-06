defmodule Pos.Repo.Migrations.TableDetails do
  use Ecto.Migration

  def change do
    alter table("order_master") do
      add :tableDetails, :string
    end
  end
end

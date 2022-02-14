defmodule Pos.StaffAttendence do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.StaffAttendence

  schema "staff_attendence" do
    field :date, :utc_datetime_usec
    field :name, :string
    field :present, :boolean, default: false
    field :restaurentId, :string
    field :staffId, :string

    timestamps()
  end

  def addAttendence(date,name,present,restaurentId,staffId) do
      %Pos.StaffAttendence{date: date,
                          name: name,
                          present: present,
                          restaurentId: restaurentId,
                          staffId: staffId}
      |> Pos.Repo.insert()
  end

  def deleteAttendence(attendenceId) do
    from(x in StaffAttendence, where: x.id == ^attendenceId) |> Pos.Repo.delete_all
  end

  def getAttendenceByRestaurentId(restaurentId) do
    from(p in StaffAttendence, where: p.restaurentId == ^restaurentId,
                               select: %{date: p.date,name: p.name,present: p.present,restaurentId: p.restaurentId,staffId: p.staffId})
    |> Pos.Repo.all()
  end

  @doc false
  def changeset(staff_attendence, attrs) do
    staff_attendence
    |> cast(attrs, [:staffId, :date, :name, :restaurentId, :present])
    |> validate_required([:staffId, :date, :name, :restaurentId, :present])
  end
end

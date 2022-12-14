defmodule Pos.OrderMaster do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.OrderMaster
  alias Pos.Queue
  alias Pos.Staff

  schema "order_master" do
    field :date, :string
    field :order_id, :string
    field :restaurent_id, :string
    field :status, :integer
    field :time, :string
    field :user_id, :string
    field :gst, :integer
    field :charge, :integer
    field :tableNumber, :integer
    field :order_date, :utc_datetime_usec
    field :s_gst, :float
    field :c_gst, :float
    field :gTotal, :string
    field :date_order, :date
    field :year, :integer
    field :month, :integer
    field :day, :integer
    field :tableDetails, :string

    timestamps(type: :utc_datetime_usec)
  end

  def insertOrderMasterData(date,order_id,restaurent_id,status,otime,user_id,gst,charge,tableNumber,order_date,total,year,month,day) do
    time = DateTime.utc_now()

    %Pos.OrderMaster{
      date: date,
      order_id: order_id,
      restaurent_id: restaurent_id,
      status: status,
      time: otime,
      user_id: user_id,
      gst: gst,
      charge: charge,
      tableDetails: tableNumber,
      order_date: order_date,
      gTotal: total,
      year: year,
      month: month,
      day: day
    }

    |> Pos.Repo.insert()

    access1 = "ALL"
    access2 = "ORDER"

    accessid = order_id
    restaurentId = restaurent_id
    section = "Order"
    task = "ADD"

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
       staffId = Enum.at(staffData, i)
       Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def updateOrderStatus(order_id,status,restaurent_id) do
    # time = DateTime.utc_now()

    Pos.Repo.get_by(OrderMaster, order_id: order_id , restaurent_id: restaurent_id)
    |> Ecto.Changeset.change(%{status: status})
    |> Pos.Repo.update()

    # access1 = "ALL"
    # access2 = "ORDER"

    # accessid = order_id
    # restaurentId = restaurent_id
    # section = "Order"
    # task = "UPDATE"

    # Queue.deleteOldUpdate(restaurentId, section, task, accessid)

    # staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    # count = Enum.count(staffData)

    # for i <- 0..count-1, i >= 0 do
    #   staffId = Enum.at(staffData, i)
      # Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    # end
  end

  def updateOrderData(order_id,restaurent_id,gst,charge,tableNumber,total) do
    Pos.Repo.get_by(OrderMaster, order_id: order_id,restaurent_id: restaurent_id)
    |> Ecto.Changeset.change(%{gst: gst,charge: charge,tableDetails: tableNumber,gTotal: total})
    |> Pos.Repo.update()
  end

  def getOrderById(restaurentId,orderId) do
    from(p in OrderMaster, where: p.restaurent_id == ^restaurentId and p.order_id == ^orderId,
    select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
              user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.order_date, s_gst: p.s_gst})
    |> Pos.Repo.all()
  end

  def getOrderDataByRestaurentId(restaurentId) do
    from(p in OrderMaster, where: p.restaurent_id == ^restaurentId,
    select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
              user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.order_date, s_gst: p.s_gst})
    |> Pos.Repo.all()
  end

  def getOrderByPagination(restaurentId,limit,offset,filterType,date) do
    cond do
      filterType == 0 ->
        if date == false do
          from(p in OrderMaster, where: p.restaurent_id == ^restaurentId,order_by: fragment("? DESC", p.inserted_at), limit: ^limit, offset: ^offset,
          select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
                    user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.inserted_at, s_gst: p.s_gst, id: p.id})
          |> Pos.Repo.all()
        else
          from(p in OrderMaster, where: p.restaurent_id == ^restaurentId and p.time == ^date,
          limit: ^limit, offset: ^offset,
          select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
                    user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.inserted_at, s_gst: p.s_gst, id: p.id})
          |> Pos.Repo.all()
        end



      filterType == 1 ->
        if date == false do
          from(p in OrderMaster, where: p.restaurent_id == ^restaurentId and p.status == 0,order_by: fragment("? DESC", p.inserted_at), limit: ^limit, offset: ^offset,
          select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
                    user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.order_date, s_gst: p.s_gst, id: p.id})
          |> Pos.Repo.all()
        else
          from(p in OrderMaster, where: p.restaurent_id == ^restaurentId and p.status == 0 and p.time == ^date,
          order_by: fragment("? DESC", p.inserted_at), limit: ^limit, offset: ^offset,
          select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
                    user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.order_date, s_gst: p.s_gst, id: p.id})
          |> Pos.Repo.all()
        end


      filterType == 2 ->
        if date == false do
          from(p in OrderMaster, where: p.restaurent_id == ^restaurentId and p.status > 0 and p.status < 4,order_by: fragment("? DESC", p.inserted_at), limit: ^limit, offset: ^offset,
          select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
                    user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.order_date, s_gst: p.s_gst, id: p.id})
          |> Pos.Repo.all()
        else
          from(p in OrderMaster, where: p.restaurent_id == ^restaurentId and p.status > 0 and p.status < 4 and p.time == ^date,
          order_by: fragment("? DESC", p.inserted_at), limit: ^limit, offset: ^offset,
          select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
                    user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.order_date, s_gst: p.s_gst, id: p.id})
          |> Pos.Repo.all()
        end



      filterType == 3 ->
        if date == false do
          from(p in OrderMaster, where: p.restaurent_id == ^restaurentId and p.status == 4,order_by: fragment("? DESC", p.inserted_at), limit: ^limit, offset: ^offset,
          select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
                    user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.order_date, s_gst: p.s_gst, id: p.id})
          |> Pos.Repo.all()
        else
          from(p in OrderMaster, where: p.restaurent_id == ^restaurentId and p.status == 4 and p.time == ^date,
          order_by: fragment("? DESC", p.inserted_at), limit: ^limit, offset: ^offset,
          select: %{order_id: p.order_id, date: p.date, restaurent_id: p.restaurent_id, status: p.status, time: p.time,
                    user_id: p.user_id, gst: p.gst, charge: p.charge, tableNumber: p.tableDetails, order_date: p.order_date, s_gst: p.s_gst, id: p.id})
          |> Pos.Repo.all()
        end


    end

  end

  def getOrderByDate(restaurentId,date) do
    # p.year >= ^syear and p.year <= ^eyear and p.month >= ^smonth and p.month <= ^emonth and p.day >= ^sday and p.day <= ^eday
    from(p in OrderMaster, where: p.restaurent_id == ^restaurentId and p.time == ^date and p.status > 0 and p.status < 4,
    select: %{order_id: p.order_id, time: p.time, gst: p.gst, charge: p.charge, order_date: p.order_date,})
    |> Pos.Repo.all()
  end

  @doc false
  def changeset(order_master, attrs) do
    order_master
    |> cast(attrs, [:order_id, :time, :status, :date, :restaurent_id, :user_id, :gst, :charge, :tableNumber, :order_date, :s_gst, :c_gst, :gTotal, :date_order, :year, :month, :day, :tableDetails])
    |> validate_required([:order_id, :time, :status, :date, :restaurent_id, :user_id, :gst, :chargez, :tableNumber, :order_date, :s_gst, :c_gst, :gTotal, :date_order, :year, :month, :day, :tableDetails])
  end
end

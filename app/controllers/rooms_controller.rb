class RoomsController < ApplicationController
  before_action :set_room, only: [:show, :edit, :update, :destroy]
  before_action :set_property_room, only: [:sync, :sync_zoopla, :sync_rightmove]
  include Pagy::Backend

  # GET /rooms
  # GET /rooms.json
  def index
    @property = Property.find params[:property_id]
    @rooms = @property.rooms.joins(:property)
    @filterrific = initialize_filterrific(
      @rooms,
      params[:filterrific],
      select_options: {
        sorted_by: @rooms.options_for_sorted_by
      },
      persistence_id: "rooms_key",
      default_filter_params: {},
      sanitize_params: true,
      ) || return
    @pagy, @rooms = pagy(@filterrific.find, items: 10)

    respond_to do |format|
      format.html
      format.js
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
  end

  # GET /rooms/new
  def new
    @property = Property.find params[:property_id]
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @property = Property.find params[:property_id]
    if @property.present?
      @room = @property.rooms.new(room_params)
      respond_to do |format|
        if @room.save
          @room.property.increment(:number_of_bedrooms)
          format.html { redirect_to @room, notice: I18n.t('room.create') }
          format.json { render :show, status: :created, location: @room }
        else
          format.html { render :new }
          format.json { render json: @room.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @room, alert: "Property not found" }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room.destroy
    @room.property.decrement(:number_of_bedrooms)
    respond_to do |format|
      format.html { redirect_to property_path(@room.property), notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def filter_rooms
    filterrific_year = params[:year]
    rooms = Room.all
    tenancy_rooms = rooms.joins(:tenancies)
    total_booked_rooms_for_the_year = tenancy_rooms.where("tenancies.year = ? and tenancies.booking_status = ?", filterrific_year, 2)
    rooms_under_booking = tenancy_rooms.where("tenancies.year = ? and tenancies.booking_status = ?", filterrific_year, 1)
    ids = total_booked_rooms_for_the_year.ids + rooms_under_booking.ids
    available_rooms = rooms.where.not(id: ids)
    if (params[:return_object].present? && params[:return_object])
      available_rooms = available_rooms
    end
    total_booked_rooms_for_the_year = total_booked_rooms_for_the_year
    if (params[:return_object].present? && params[:return_object])
      total_booked_rooms_for_the_year = total_booked_rooms_for_the_year
    end
    respond_to do |format|
      format.json { render json: {booked_rooms: total_booked_rooms_for_the_year.uniq.count, available_rooms: available_rooms.uniq.count, rooms_under_booking: rooms_under_booking.uniq.count}, status: :ok }
    end
  end

  ## sync
  def sync
  end

  def sync_rightmove
    @room.create_rightmove
    @room = Room.find_by(id: @room.id)
  end

  def sync_zoopla
    @room.create_in_zoopla
    @room = Room.find_by(id: @room.id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    def set_property_room
      @property = Property.find params[:property_id]
      @room = @property.rooms.find_by(id: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:number, :description, :tenancy_start, :tenancy_end, :list_price, :property_id,
                                   :landlord_id, :ensuite, :dimensions, :availability
                                  )
    end
end

class EventsController < ApplicationController
  include EventsHelper

  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :verify_authenticity_token, only: :create

  include Pagy::Backend

  def index
    @filterrific = initialize_filterrific(
      Event,
      params[:filterrific],
      select_options: {
          sorted_by: Event.options_for_sorted_by
      },
      persistence_id: "events_key",
      default_filter_params: {},
      sanitize_params: true,
      ) || return
    @pagy, @events = pagy(@filterrific.find, items: 10)

    respond_to do |format|
      format.html
      format.js
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  def show
    get_event_properties
    @event_props = Property.where(id: @event_property_ids)
    @agent = User.where(id: @event.event_users.pluck(:user_id)).map{ |u| u.full_name }.join(", ")
  end

  def new
    @event = Event.new
    get_event_properties
    @modal = false if params[:modal] && params[:modal] == 'false'
    session[:selected_data] = params[:selected_data] if params[:selected_data]
  end

  def edit
    @event = Event.find(params[:id])
    @modal = false if params[:modal] && params[:modal] == 'false'
    get_event_properties
  end

  def create
    get_event_properties
    params_value = event_params_managed
    start_time = params_value[:start]
    @event = Event.new(params_value)
    if !params["user_id"].nil?
      params["user_id"].each do |user_id|
        @event.event_users.build(user_id: user_id)
      end
    end
    if @event.save
      session.delete(:selected_date)
      @selected_date = params_value["start"].to_date
      @events = Event.where("date(start) = ?", @selected_date)
      @users = User.all
      args = { selected_date: @selected_date }
      args.merge!(visit: true) if @event.block_out_event?
      redirect_to calendar_index_path(args)
    else
      render :new
    end
  end

  def update
    get_event_properties
    if(params["form-update"])
      params_value = event_params_managed
      @event.event_users.destroy_all
      if !params["user_id"].nil?
        params["user_id"].each do |user_id|
          @event.event_users.build(user_id: user_id)
        end
      end
      @event.update(params_value)
      @selected_date = params_value["start"].to_date
      @events = Event.where("date(start) = ?", @selected_date)
    else
      params_value = drag_drop_params
      params_value["start"] = Date.parse(params["event"]["start"]).strftime("%Y-%m-%d")+ ' ' +Time.parse(params["event"]["start"]).strftime('%H:%M:%S') if params["event"]["start"].present?
      params_value["end"] = Date.parse(params["event"]["start"]).strftime("%Y-%m-%d")+ ' ' +Time.parse(params["event"]["end"]).strftime('%H:%M:%S') if params["event"]["start"].present?
      @event.event_users.destroy_all if !params["user_id"].nil?
      @event.event_users.build(user_id: params["user_id"]) if !params["user_id"].nil?
      @event.update(params_value)
      @selected_date = params["event"]["start"].to_date
      @events = Event.where("date(start) = ?", @selected_date)
    end
    @users = User.all

    args = { selected_date: @selected_date }
    args.merge!(visit: true) if @event.block_out_event?
    redirect_to calendar_index_path(args)
  end

  def destroy
    @event.destroy
    flash[:notice] = 'Event was successfully destroyed'
    redirect_to calendar_index_path
  end

  def events_by_date
    @events = Event.where("date(start) = ?", params[:start_date].to_date)
    @users = User.all
    @selected_date = params[:start_date].to_date
  end

  def reminder
    time = Time.now + 25.hours
    @events = Event.where(start: time..(time + 10.minutes), confirmed: false)
    render json: { count: @events.count, ids: @events.ids }
  end

  def done_reminder
    @events = Event.where(id: params[:ids])
    updated = @events.present? ? @events.update_all(confirmed: true) : false
    render json: { success: updated }
  end

  def get_event_properties
    @event_property_ids = @event.present? ?  @event.properties.ids : []
    @properties = Property.order(:street, :id)
    # @properties = Property.includes(:rooms, :tenancies).order(:street, :id)
    @year = params[:year].present? ? params[:year] : @current_year
  end

  private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params_managed
      params_value = event_params
      start_date = Date.parse(params["start_date"]).strftime("%Y-%m-%d")
      end_date = start_date
      params_value["start"] =  start_date+" " +Time.parse(params["event"]["start(4i)"] + ':' + params["event"]["start(5i)"]).strftime('%H:%M:%S')
      params_value["end"] = end_date+" " +Time.parse(params["event"]["end(4i)"] + ':' + params["event"]["end(5i)"]).strftime('%H:%M:%S')
      params_value["property_ids"] = params_value["property_ids"]&.split
      return params_value
    end

    def drag_drop_params
      params.require(:event).permit(:start, :end)
    end
    def event_params
      params.require(:event).permit(:event_type, :notes, :property_id, :client_name, :client_contact_number,
                                    :appointment_info, :viewing_type, :budget, :client_email, :client_confirmation,
                                    :budget_per_month, :budget_per_week, :event_title, :property_ids)
    end

    # def agent_available(users,start_time)
    #   users.each do |user_id|
    #     events = Event.where(start: start_time)
    #     events.each do |event|
    #       agent = event.event_users.where(user_id: user_id) if !event.nil?
    #       if !agent.blank?
    #         return false
    #       else
    #         return true
    #       end
    #     end
    #   end
    # end
end

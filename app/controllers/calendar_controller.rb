class CalendarController < ApplicationController
  def index
    @selected_date = params[:selected_date] if params[:selected_date].present?
    @properties     = Property.all
    @rooms          = Room.all
    @rooms_let      = Room.where(let_status: 1)
    @rooms_not_let  = Room.where(let_status: 0)
    @events         = Event.all
    @viewings       = Event.where(event_type: 1)
    @maintainence   = Event.where(event_type: 2)
    @holidays       = Event.where(event_type: 4)
    @landlords      = Landlord.all
    @users          = User.all
  end
end

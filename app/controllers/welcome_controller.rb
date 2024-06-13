class WelcomeController < ApplicationController
  def index
    today = Date.today
    @year = @current_year
    @selected_date          = params[:selected_date] if params[:selected_date].present?
    @properties             = Property.all
    @rooms                  = Room.all
    # @rooms_let              = Room.where(let_status: 1) # Not in use
    # @rooms_not_let          = Room.where(let_status: 0) # Not in use
    @events                 = Event.all
    @viewings               = Event.where(event_type: 1)
    @maintenance            = Event.where(event_type: 2)
    @holidays               = Event.where(event_type: 4)
    @landlords              = Landlord.all
    @users                  = User.all
    @user_events            = Event.joins(:event_users).where(event_users: {user_id: current_user.id}).where(events: {start: Date.today.all_day}).order(:start)
    @today_events           = Event.where("DATE(events.start) = ?", Date.today.strftime)
    @week_events            = Event.where("DATE(events.start) >= ? AND DATE(events.end) <= ?", Date.today.beginning_of_week.strftime, Date.today.end_of_week.strftime)
    @month_events           = Event.where("DATE(events.start) >= ? AND DATE(events.end) <= ?", Date.today.beginning_of_month.strftime, Date.today.end_of_month.strftime)
    @tenancies              = Tenancy.all
    @unsigned_booking_form  = @tenancies.where(form_submitted: 0)
    @unsigned_agreement     = @tenancies.where(signed_tenancy_agreement: 0)
    @today_events_for_non_admin_users = Event.order(:start).today_events_for_non_admin_users
    @room_tenancies = @rooms.joins(:tenancies)
    @booked_rooms = @room_tenancies.where('tenancies.booking_status = ?', 1).count
    @completed_rooms = @room_tenancies.where('tenancies.booking_status = ?', 2).count
    @available_rooms = @rooms.where(availability: true).count
    @next_month_expire_tenancies = @tenancies.where("tenancy_end BETWEEN ? AND ?", Time.now, Time.now + 30.days).count
    @next_month_expire_documents = ComplianceDocument.where('extract(month from document_expiry) = ? AND extract(year from document_expiry) = ?', (Time.now + 1.month).strftime('%m'), (Time.now + 1.month).strftime('%Y')).count
    @properties_listed = Property.where('list_on_3rd_party_websites = true').count
  end

  def properties
    rooms = Room.joins(:property)
    tenancy_rooms = rooms.joins(:tenancies)
    @status = params[:status]
    year = params[:year] ? params[:year] : @current_year
    notice_rooms = tenancy_rooms.where("tenancies.year = ? and tenancies.booking_status = ?", year, 3)
    complete_rooms = tenancy_rooms.where("tenancies.year = ? and tenancies.booking_status = ?", year, 2)
    booking_rooms = tenancy_rooms.where("tenancies.year = ? and tenancies.booking_status = ?", year, 1)
    ids = complete_rooms.ids + booking_rooms.ids
    available_rooms = rooms.where.not(id: ids)
    # @rooms = @status == 'available' ? available_rooms : @status == 'booking' ? booking_rooms : complete_rooms
    case @status
      when 'available'
        @rooms = available_rooms
        @notice_rooms = notice_rooms
      when 'booking'
        @rooms = booking_rooms
      when 'complete'
        @rooms = complete_rooms
      when 'notice'
        @rooms = notice_rooms
      else
    end

    @booking_tenancies = Tenancy.where(room_id: @rooms.ids, year: year, booking_status: 1).group_by(&:room_id) if @status == 'booking'

    if @status == 'booking'
      @rooms = @rooms.order('tenancies.dashboard_link_mail_at, properties.street, properties.id, rooms.number').uniq
    elsif @status == 'available'
      @rooms = @rooms.order('properties.street, properties.id, rooms.number').uniq
      @notice_rooms = @notice_rooms.order('properties.street, properties.id, rooms.number').uniq
    else
      @rooms = @rooms.order('properties.street, properties.id, rooms.number').uniq
    end
  end
end

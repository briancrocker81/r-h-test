module ListingsHelper
  def get_tenancies_btwn_years(room, filterrific_year, status)
    tenancies = room.tenancies.not_failed.where("tenancies.year= ?", filterrific_year).order(:tenancy_start)
    tenancies = tenancies.where("tenancies.booking_status = ?", status) if [1, 2].include?(status)
    if tenancies.count >= 1
      {tenancies: tenancies, tenant_present: true}
    else
      {tenancies: "", tenant_present: false}
    end
  end

  def available_for_the_year(year, room)
    tenancies = check_room_completed_availability(year, room)
    return tenancies.count > 0 ? false : true
  end

  def check_room_completed_availability(year, room)
    date = Date.today
    month = date.month
    cur_year = month > 9 ? (date.year + 1) : (date.year)
    tenancies = room.tenancies.where(year: year, booking_status: 2).where.not(
      'DATE(tenancy_end) < ?', ("31/08/#{cur_year.to_i}").to_date
    )
    return tenancies
  end

  def last_completed_date(room)
    date = Date.today
    month = date.month
    cur_year = month > 9 ? (date.year + 1) : (date.year)
    year  = @current_year
    tenancies = room.tenancies.where(year: year, booking_status: 2).where(
      'DATE(tenancy_end) < ?', ("31/08/#{cur_year.to_i}").to_date
    )
    last_date = tenancies.count > 0 ? tenancies.order('tenancy_end asc').last.tenancy_end : ''
    return last_date
  end

  def property_titles(room)
    if room.property.address_line_2?
      fullproperty = "#{room.property.property_name}, #{room.property.address_line_2}"
    else
      fullproperty = room.property.property_name
    end
    return fullproperty
  end
end

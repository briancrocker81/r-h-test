module RoomsHelper
  def has_tenant(room)
    #user.email if user && user.email.present?
    room.tenancy.find_by(room_id: room.id).tenant_full_name
  end

  def check_room_availability(room)
    property_rooms = room.property.rooms.count
    available_rooms = room.property.rooms.available.count
    div = ''
    if property_rooms == available_rooms
      div = '<div class="available col-1 bg-success">'+available_rooms.to_s+'</div>'
    elsif available_rooms<property_rooms && available_rooms != 0
      div = '<div class="available col-1 bg-warning">'+available_rooms.to_s+'</div>'
    else
      div = '<div class="available col-1 bg-danger">'+available_rooms.to_s+'</div>'
    end
    return div
  end

  def check_property_availability(property)
    pr_rooms = property.rooms.eager_load(:tenancies)
    pr_room_count = pr_rooms.count
    tenancy_rooms = Tenancy.where(booking_status: 2).pluck(:room_id).uniq
    property_room_count = pr_rooms.where.not(id: tenancy_rooms).count
    currently_occupied = pr_rooms.where('tenancies.booking_status = ?', 2).count

    div = ''
    class_name = (pr_room_count > 0 && property_room_count == pr_room_count) ? 'bg-success' : currently_occupied >= 1 ? 'bg-warning' : 'bg-danger'
    div = "<div class='available #{class_name}'>"+property_room_count.to_s+'</div>'
    return div
  end

  def property_available(property, type = "available_ratio")
    rooms = property.rooms
    property_total_rooms = rooms.count
    property_available_rooms = rooms.where(availability: true).count
    property_currently_occupied_rooms = rooms.where(availability: false).count
    value = ''
    if type == "class"
      if property_currently_occupied_rooms == 0
        value = 'available'
      elsif property_currently_occupied_rooms > 0
        value = 'partially-available'
      elsif property_available_rooms == 0
        value = 'booked'
      end
    else
      if property_currently_occupied_rooms == 0
        value = property_available_rooms.to_s+"/"+property_total_rooms.to_s+' ( '+' <span style="color: #3a7e37;"> Available</span> )'
      elsif property_currently_occupied_rooms > 0
        avl_txt = property_available_rooms > 1 ? property_available_rooms.to_s+' rooms' : property_available_rooms.to_s+' room'
        value = property_available_rooms.to_s+"/"+property_total_rooms.to_s+' ( '+ ' <span style="color: #de9040;"> '+avl_txt+' left</span> )'
      elsif property_available_rooms == 0
        value = property_available_rooms.to_s+"/"+property_total_rooms.to_s+' ( '+' <span style="color: #dc4545;"> Fully booked</span> )'
      end
    end
    return value
  end

  def property_num_available(property)
    rooms = property.rooms
    property_total_rooms = rooms.count
    property_available_rooms = rooms.where(availability: true).count
    property_currently_occupied_rooms = rooms.where(availability: false).count
    value = ''

    if property_currently_occupied_rooms == 0
      value = property_available_rooms.to_s+"/"+property_total_rooms.to_s
    elsif property_currently_occupied_rooms > 0
      avl_txt = property_available_rooms > 1 ? property_available_rooms.to_s+' rooms' : property_available_rooms.to_s+' room'
      value = property_available_rooms.to_s+"/"+property_total_rooms.to_s
    elsif property_available_rooms == 0
      value = property_available_rooms.to_s+"/"+property_total_rooms.to_s
    end

    return value
  end

  def filter_room(year)
    rooms = Room.all
    tenancy_rooms = rooms.joins(:tenancies)
    notice_rooms = tenancy_rooms.where("tenancies.year = ? and tenancies.booking_status = ?", year, 3)
    total_complete_rooms_for_the_year = tenancy_rooms.where("tenancies.year = ? and tenancies.booking_status = ?", year, 2)
    rooms_under_booking = tenancy_rooms.where("tenancies.year = ? and tenancies.booking_status = ?", year, 1)
    ids = total_complete_rooms_for_the_year.ids + rooms_under_booking.ids
    available_rooms = rooms.where.not(id: ids)
    if (params[:return_object].present? && params[:return_object])
      available_rooms = available_rooms
    end
    total_complete_rooms_for_the_year = total_complete_rooms_for_the_year
    if (params[:return_object].present? && params[:return_object])
      total_complete_rooms_for_the_year = total_complete_rooms_for_the_year
    end


    return {
      notice_rooms: notice_rooms.uniq.count,
      booked_rooms: total_complete_rooms_for_the_year.uniq.count,
      available_rooms: available_rooms.uniq.count,
      rooms_under_booking: rooms_under_booking.uniq.count
    }
  end
end

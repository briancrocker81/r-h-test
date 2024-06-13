module PropertiesHelper
  include Pagy::Frontend

  def rental_type (property, room)
    if property.rental_type.nil?
      return "<span style='color:red;'>Not defined, Please update!</span>"
    elsif room.present?
      property.rental_type? ? 'Room-'+room.number : 'By Home'
    else
      property.rental_type? ? 'By Room' : 'By Home'
    end
  end

  def get_property_conversations(property_id)
    @conversations = Conversation.where(property_id: property_id)
  end

  def property_rate(property)
    if property.rental_type == 0
      !property.home_rental_price.nil? ? "£#{number_with_delimiter(sprintf("%.2f",property.home_rental_price.to_f), delimiter: ',')}" : 'N/A'
    else
      last_room_list_price = property.rooms.where.not(list_price: nil).pluck(:list_price).reject(&:blank?)
      list_price = last_room_list_price.sort.uniq
      !list_price.empty? ? (list_price.count > 1 ? "£#{number_with_delimiter(sprintf("%.2f",list_price[0]), delimiter: ',')} - £#{number_with_delimiter(sprintf("%.2f",list_price[-1]), delimiter: ',')}" : "£#{number_with_delimiter(sprintf("%.2f",list_price[0]), delimiter: ',')}") : 'N/A'
    end
  end

  def bin_options option
    if option == 0
      'Monday'
    elsif option == 1
      'Tuesday'
    elsif option == 2
      'Wednesday'
    elsif option == 3
      'Thursday'
    elsif option == 4
      'Friday'
    elsif option == 5
      'Saturday'
    elsif option == 6
      'Sunday'
    else
      'Undefined'
    end
  end

  # ['Garden', 0], ['Yard', 1], ['Outside space', 2], ['None', 3]
  def outside_options option
    if option == 0
      'Garden'
    elsif option == 1
      'Yard'
    elsif option == 2
      'Outside Space'
    elsif option == 3
      'None'
    else
      'Undefined'
    end
  end

  # ['Private', 0], ['Off street', 1], ['Permit', 2], ['Nearby', 3], ['None', 4]
  def parking_options option
    if option == 0
      'Private'
    elsif option == 1
      'Off street'
    elsif option == 2
      'Permit'
    elsif option == 3
      'Nearby'
    elsif option == 4
      'None'
    else
      'Undefined'
    end
  end

  # ['All', 0], ['Some', 1], ['None', 2]
  def ensuite_options option
    if option == 0
      'All'
    elsif option == 1
      'Some'
    elsif option == 2
      'None'
    else
      'Undefined'
    end
  end
end

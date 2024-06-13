module ApplicationHelper
  require 'date'
  require 'libreconv'

  def clean_string (string)
    string.gsub(" ", "-").downcase
    return string
  end

  def uk_date
    date
  end

  def yes_no (bool)
    yes = '<span class="badge badge-success">Yes</span>'
    no = '<span class="badge badge-warning">No</span>'
    bool ? yes.html_safe : no.html_safe
  end

  def document_badge (bool, icon, name)
    yes = '<span class="badge badge-success"><div class="box"><i class="'+icon+'"></i><h5 class="mb-0">'+name+'</h5></div></span>'
    no = '<span class="badge badge-danger"><div class="box"><i class="'+icon+'"></i><h5 class="mb-0">'+name+'</h5></div></span>'
    return bool ? yes.html_safe : no.html_safe
  end

  def document_badge_date (bool, icon, name, date)
    yes = '<span class="badge badge-success"><div class="box"><i class="'+icon+'"></i><h5>'+name+'</h5><p>'+date.strftime('%m/%d/%Y')+'</p>'+date_expired(date)+'</div></span>'
    no = '<span class="badge badge-danger"><div class="box"><i class="'+icon+'"></i><h5>'+name+'</h5><p>'+date.strftime('%m/%d/%Y')+'</p></div></span>'
    return bool ? yes.html_safe : no.html_safe
  end

  def document_block (bool, icon, name)
    yes = '<span class="badge badge-success flex-center"><div class="box"><i class="'+icon+'"></i><h5>'+name+'</h5></div></span>'
    no =  '<span class="badge badge-danger flex-center"><div class="box"><i class="'+icon+'"></i><h5>'+name+'</h5></div></span>'
    return bool ? yes.html_safe : no.html_safe
  end

  def date_expired(date)
    if date.to_date <= Time.now
      e = '<p class="doc-expired" title="Document expired"><i class="fas fa-exclamation-triangle"></i></p>'
    else
      e = ''
    end
    return e
  end

  def furnished (state)
    if state == 0
      state = 'Furnished'
    elsif state == 1
      state = 'Part-furnished'
    elsif state == 2
      state = 'Unfurnished'
    else
      state = ''
    end
  end

  def check_doc_is_not_pdf(doc)
    if File.extname(doc.document_file.url) != 'pdf'
      return true
    end
  end

  def prev_img(doc)
    Libreconv.convert("#{Rails.root}"+"/public"+"#{doc.document_file.url}", "#{Rails.root}/public/prev_"+doc.document_file.identifier.split('.')[0]+".pdf" )
  end

  def valid_date?(date)
    date_format = '%Y-%m-%d'
    DateTime.strptime(date.to_s, date_format)
    true
    rescue ArgumentError
    false
  end

  def lowercase_strip(string)
    s = string.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    return s
  end
  def uppercase_strip(string)
    s = string.capitalize.strip.gsub('-', ' ').gsub(/[^\w-]/, ' ')
    return s
  end

  def room_price(room)
    rooms = room.last_room_having_list_price
    if rooms.size > 0
      list_price = rooms.last.list_price
      if !list_price.nil?
        return list_price
      else
        return 0
      end
    else
      return 0
    end
  end

  def rooms
    Room.includes(:property).map{|r| [r.property.property_name+' - Room '+r.number, r.id ]}.sort.to_h
  end

  def business_years(default = true)
    date = Time.zone.now.to_date
    month = date.month
    years = []
    if month < 9
      years = ["#{(date - 1.year).strftime('%y')}/#{date.strftime('%y')}", "#{date.strftime('%y')}/#{(date + 1.year).strftime('%y')}", "#{(date - 2.year).strftime('%y')}/#{(date - 1.year).strftime('%y')}"]
      # years << "#{(date + 1.year).strftime('%y')}/#{(date + 2.years).strftime('%y')}" if default
    else
      years = ["#{date.strftime('%y')}/#{(date + 1.year).strftime('%y')}", "#{(date + 1.year).strftime('%y')}/#{(date + 2.years).strftime('%y')}", "#{(date - 1.year).strftime('%y')}/#{(date).strftime('%y')}"]
      # years << "#{(date + 2.years).strftime('%y')}/#{(date + 3.years).strftime('%y')}" if default
    end
    return years
  end

  def tel_to(number)
    link_to number, "tel:#{number}"
  end

  def number_of_weeks(start_date, end_date)
    start_date = start_date.strftime("%d/%m/%Y")
    end_date = end_date.to_time
    time_in_past = Date.parse(start_date).to_time
    time_difference = end_date - time_in_past
    (time_difference / 1.week).round(0)
  end

  def number_of_months(start_date, end_date)
    ((end_date - start_date).to_f / 365 * 12).round
  end

  def listed_status (bool, name)
    yes = "<span class='badge badge-success listed-on'>#{name}</span>"
    no = "<span class='badge badge-danger listed-on'>#{name}</span>"
    bool ? yes.html_safe : no.html_safe
  end

  def avr_dpt_display(tenancy)
    if tenancy.tenancy_is == 0
      yes_no(tenancy.tenancy_payment_items.where(item: 'AvR').where.not(date_paid: nil).where('amount_paid >= amount_due').present?)
    else
      yes_no(tenancy.deposit_paid)
    end
  end

  def room_display_type(room)
    if room == 'Home'
      room = '<i class="fas fa-home" title="Home"></i>'
    else
      room
    end
    return room.html_safe
  end

  def tenant_type_icon(tenant)
    if tenant == 0
       '<i class="fas fa-university" title="Student"></i>'
    elsif tenant == 1
      '<i class="fas fa-user-tie" title="Professional"></i>'
    end
  end

  def uk_price(price)
    number_to_currency(price, :unit => "£")
  end

  def monthly_payment_price(tenant)
    if tenant.deposit_term == 'termly'
      rate = tenant.monthly_price
    else
      rate = tenant.payment_amount
    end
    return rate
  end

end

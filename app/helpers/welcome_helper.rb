module WelcomeHelper
  def details event
    content_tag(:div, class: 'row') do
      content_tag(:div, class: 'col-2') do
        event.start.strftime("%H:%M")
      end +
      content_tag(:div, class: 'col-5') do
        event.client_name
      end +
      content_tag(:div, class: 'col-5') do
        event.client_contact_number
      end
    end
  end

  def status_title status
    case status
    when 'available'
      "Properties Available"
    when 'booking'
      "Properties Under Booking"
    when 'complete'
      "Complete Properties"
    when "notice"
      "Properties Given Notice"
    else
      "#{status} undefined"
    end
  end
end

module EventsHelper

  def get_calendar_event_type(event_type)
    case event_type
    when 1 then 'Student Viewing'
    when 2 then 'Private Viewing'
    when 3 then 'Visit'
    when 4 then 'Communal Clean'
    when 5 then 'Maintenance'
    else 'Block out diary'
    end
  end
	def dashboard_events
    if @events.count === 0
      # content_tag :div, class: "wibble" do
      #   content_tag :p do
      #     'No events'
      #   end
      # end
    else
      # Event.user_events
      # user_events.each do |event|
      #   # concat content_tag(:li, event.client_email)
      #   concat content_tag(:li, event.id )
        # @user_events.each do |event|
        #   concat content_tag(:li, today.client_email)
        #   # content_tag :ul, class: "ho9me"
        #   # concat content_tag(:li, event.id)
        #   #   concat content_tag(:li, event.user_id )
        #
        # # <ul>
        # # <li>= link_to event.client_name, edit_event_path(event) %></li>
        # #   </ul>
        # end
      # end
    end
  end


  def event_name(event)
    # ['Student Viewing', 1], ['Private Viewing', 2], ['Visit', 3], ['Communal Clean', 4], ['Maintenance', 5], ['Block out diary', 6] set from event/_form.html.erb
    if event.event_type == 1
      event_name = 'Student Viewing'
    elsif event.event_type == 2
      event_name = 'Private Viewing'
    elsif event.event_type == 3
      event_name = 'Visit'
    elsif event.event_type == 4
      event_name = 'Communal Clean'
    elsif event.event_type == 5
      event_name = 'Maintenance'
    elsif event.event_type == 6
      event_name = 'Diary block'
    end
  end

  def event_time(event)
    event.start.strftime('%H:%M') + ' - ' + event.end.strftime('%H:%M')
  end
end

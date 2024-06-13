class EventMailer < ApplicationMailer
  # default from: 'checkin@cityletsplymouth.co.uk'

  def notify_event_creation(event)
    @event = event
    @properties = @event.properties
    if @event.client_email.present?
      p 'Has email'
      mail(to: @event.client_email, subject: 'Your Property Viewing Has Been Booked!')
    else
      p 'No email'
    end
  end

  def self.send_event_mail(id, property_id, subject, status)
    event = Event.find_by(id: id)
    property = Property.includes(rooms: :tenancies).find_by(id: property_id)
    rooms = property.rooms
    ids = event.tenancy_ids
    rooms.each do |room|
      tenants = room.tenancies.where('Date(tenancy_start) < ? and Date(tenancy_end) > ?', Date.today, Date.today).where(booking_status: 'complete')
      tenants.each do |tenant|
        if status || !ids.include?(tenant.id)
          ids << tenant.id
          send_event_mail_to_tenat(event, property, tenant, subject).deliver
        end
      end
      event.update_columns(tenancy_ids: ids)
    end
  end

  def send_event_mail_to_client(id, subject)
    @event = Event.find(id)
    @properties = @event.properties
    mail(to: @event.client_email, subject: subject)
  end

  def send_event_mail_to_tenat(event, property, tenant, subject)
    @event = event
    @property = property
    @tenant = tenant
    mail(to: @tenant.email, subject: subject) do |format|
      format.html { render 'send_event_mail' }
    end
  end
end

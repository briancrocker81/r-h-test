class Event < ApplicationRecord
  serialize :tenancy_ids, Array
  after_create :send_booked_event_email

  attr_accessor :date_range

  has_many :events_properties, dependent: :delete_all
  has_many :properties, through: :events_properties
  has_many :event_users, dependent: :destroy
  has_many :users, through: :event_users

  #validation
  validates :start, :end, :event_type, presence: true
  validates :client_contact_number, presence: true, unless: :block_out_event?

  scope :today_events_for_non_admin_users, -> { joins(:event_users, :users).where.not(users: {role: 'Admin'}).where(events: {start: Date.today.all_day}).uniq }

  def end_time_after_start_time?
    errors.add(:end, "must be after start time") if self.end < self.start
  end

  def expiration_date_cannot_be_in_the_past
    errors.add(:expiration_date, "can't be in the past") if expiration_date.present? && expiration_date < Date.today
  end

  def viewer_status
    case viewing_type
    when 1 then 'Student'
    when 2 then 'Graduate'
    when 3 then 'Professional'
    when 4 then 'Family'
    end
  end

  def event_title
    property_beds = properties.pluck(:number_of_bedrooms).reject(&:blank?).uniq.join(' , ') if properties.present?

    sections = [
      { icon: '<i class="fas fa-user"></i>', content: ERB::Util.html_escape(client_name.to_s) },
      { icon: '<i class="fas fa-phone"></i>', content: ERB::Util.html_escape(client_contact_number.to_s) },
      { icon: '<i class="fas fa-bed"></i>', content: ERB::Util.html_escape(property_beds.to_s) }
    ]

    # Show "Appointment Info" if it's not blank, otherwise show "Event Type"
    info_or_type = appointment_info.present? ? appointment_info : get_event_type(event_type).to_s
    sections.append({ icon: '<i class="fas fa-info-circle"></i>', content: ERB::Util.html_escape(info_or_type) })

    non_blank_sections = sections.select { |section| section[:content].present? }

    event_detail = non_blank_sections.map { |section| "#{section[:icon]} #{section[:content]}" }.join('<br>').html_safe

    ERB::Util.html_escape(event_detail)
  end

  def get_event_type(event_type)
    case event_type
    when 1 then 'Student Viewing'
    when 2 then 'Private Viewing'
    when 3 then 'Visit'
    when 4 then 'Communal Clean'
    when 5 then 'Maintenance'
    else 'Block out diary'
    end
  end
  # def all_day_event?
  #   self.start == self.start.midnight && self.end == self.end.midnight ? true : false
  # end

  def send_event_email
    return unless ManageAutomationMail.where(mail_type: 'Event Mailer', automation: true).where('mail_methods LIKE ?', "%#{'send_event_mail_to_tenat'}%").present?
    return unless Time.current >= (start - 25.hours)

    EventMailer.send_event_mail_to_client(id, 'Appointment Scheduled').deliver_now if client_email.present?
    properties.uniq.each do |property|
      EventMailer.send_event_mail(id, property.id, 'Appointment Scheduled', true)
    end
    self.update_columns(mail_sent: true, mail_sent_at: Time.now)
  end

  def send_booked_event_email
    if event_type == 1 || event_type == 2
      EventMailer.notify_event_creation(self).deliver_now
    end
  end

  filterrific(
    default_filter_params: { sorted_by: 'client_name_asc' },
    available_filters: [
      :sorted_by,
      :search_query
    ]
  )

  terms_query = Arel.sql("LOWER(events.client_name) LIKE ? OR LOWER(events.created_at) LIKE ?")
  scope :search_query, ->(query) {
    return nil  if query.blank?
    terms = query.downcase.split(/\s+/)
    terms = terms.map{|term| term.gsub(/\*$/, '')}.map{|term| "%#{term}%"}
    num_or_conditions = 2
    where(
      terms.map {  |term|
        terms_query
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^client_name/
      order(Arel.sql("LOWER(events.client_name) #{direction}"))
    when /^created_at_/
      order(Arel.sql("events.created_at #{direction}"))
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
      ['Client Name (a-z)', 'client_name_asc'],
      ['Client Name (z-a)', 'client_name_desc'],
      ['Created at (Newest first)', 'created_at_desc'],
      ['Created at (Oldest first)', 'created_at_asc']
    ]
  end

  def block_out_event?
    [3, 4, 5, 6].include?(event_type)
  end
end

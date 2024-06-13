class Tenancy < ApplicationRecord
  mount_base64_uploader :signature, AttachmentUploader, file_name: -> (t) { "tenancy-sig-"+t.id.to_s }
  mount_base64_uploader :tenancy_agreement_signature, AttachmentUploader, file_name: -> (t) { "tenancy-agreement-sig-"+t.id.to_s }
  TENANCY_TYPE = [["Room", 1], ["Professional", 3], ["Professional", 4], ["Professional", 5]]
  PAYMENT_STATUS = ["unpaid", "paid"]
  BOOKING_STATUS = ["available", "booking", "complete", "notice"]
  SALARY_TYPES = ["annual", "monthly", "weekly"]
  # YEARS = ['21/22','22/23', '23/24']
  YEARS = ['22/23','23/24', '24/25']

  ## enum
  enum booking_status: %w(available booking complete notice)

  attr_accessor :validate_doc, :validate_booking, :skip_sending_dashboard_link, :term_due_dates, :rolled, :payment_edit

  ## Validation
  validates_presence_of :email
  validates_presence_of :year
  validate  :confirm_tenancy_field
  validate  :read_doc_field
  validate  :accept_agreement_field
  validate  :emergency_details, on: :update
  validates :first_name, presence: true
  validates :surname, presence: true
  validate  :tenancy_mobile, on: :update
  validate  :advance_rent_card_details
  validate  :check_availability, on: :create

  ## Association
  has_many :tenancy_identifications, dependent: :destroy
  belongs_to :room
  has_many :tenancy_documents, dependent: :destroy
  # has_one :company
  has_one :student_course_detail, dependent: :destroy
  has_one :guarantor, dependent: :destroy
  has_many :criminal_records, dependent: :destroy
  has_many :tenancy_payment_items, dependent: :destroy
  has_many :tenancy_staff_conversations, dependent: :destroy
  has_many :tenancy_histories, dependent: :destroy
  has_one :professional_detail, dependent: :destroy
  has_many :sender_tenancy_staff_messages, as: :sender, class_name: 'TenancyStaffMessage'
  has_many :receiver_tenancy_staff_messages, as: :receiver, class_name: 'TenancyStaffMessage'
  has_many :additional_tenants, dependent: :destroy

  amoeba do
    enable
    nullify :uri_string
    nullify :dashboard_link_mail
    nullify :dashboard_link_visited
    nullify :dashboard_link_mail_at
    nullify :dashboard_link_mail_number_of_time
    include_association %i[tenancy_documents tenancy_identifications guarantor tenancy_staff_conversations tenancy_histories]
    customize(lambda do |op, np|
      np.signature = op.signature

      time = DateTime.parse("01/09/#{Date.today.year}")
      amount_due = op.tenancy_payment_items.last.amount_due
      item = op.tenancy_payment_items.last.item
      item_type = op.tenancy_payment_items.last.item_type
      12.times do |n|
        item_year = "#{time.year - 2000}/#{time.year - 1999}"
        np.tenancy_payment_items.build(
          amount_due: amount_due,
          due_date: time.beginning_of_month.end_of_day,
          item_year: item_year,
          item: item,
          item_type: item_type
        )
        time += 1.month
      end
    end)
  end

  ## Nested Fields
  accepts_nested_attributes_for :guarantor, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :tenancy_identifications, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :criminal_records, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :tenancy_documents, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :student_course_detail, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :professional_detail, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :additional_tenants, reject_if: :all_blank, allow_destroy: true

  ## Filter
  filterrific(
    default_filter_params: { sorted_by: 'surname_asc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :search_by_year_range
    ]
  )

  ## Scope
  default_scope { where(archived: false) }

  scope :competing_tenancies_for, ->(tenancy) {
    where(room_id: tenancy.room_id)
    .where.not(id: tenancy.id)
    .where('? < tenancy_end', tenancy.tenancy_start)
    .where('? > tenancy_start', tenancy.tenancy_end)
  }
  scope :not_failed, -> { where(failed_to_book_at: nil) }
  scope :archived, -> { where(archived: true) }
  scope :not_archived, -> { where.not(archived: true) }
  scope :search_query, ->(query) {
    return nil  if query.blank?
    terms = query.downcase.split(/\s+/)
    terms = terms.map{|term| term.gsub(/\*$/, '')}.map{|term| "%#{term}%"}
    num_or_conditions = 4
    where(
      terms.map {  |term|
        "LOWER(tenancies.first_name) LIKE ? OR LOWER(tenancies.surname) LIKE ? OR LOWER(tenancies.email) LIKE ? OR LOWER(properties.street) LIKE ?"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    ).joins(room: :property)
  }

  scope :search_by_year_range, ->(query){
    from_date = Date.strptime(query.split("/")[0],"%y").year.to_s+'-'+'09'+'-'+'01'
    end_date = Date.strptime(query.split("/")[1],"%y").year.to_s+'-'+'08'+'-'+'17'
    return nil if query.blank? || (from_date == "" || end_date == "")
    # if query.split("/")[0] == "00" && query.split("/")[1] == "99"
    #   where("tenancies.tenancy_start < ? AND tenancies.tenancy_end < ?", Time.now.to_date, Time.now.to_date)
    # end
    where("tenancies.tenancy_start BETWEEN ? AND ?", from_date, end_date)
  }

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^surname/
      order("LOWER(tenancies.surname) #{direction}")
    when /^tenancy_start/
      order("tenancies.tenancy_start #{direction}")
    when /^tenancy_end/
      order("tenancies.tenancy_end #{direction}")
    when /^tenant_type/
      order("tenancies.tenant_type #{direction}")
    when /^year/
      order("tenancies.year #{direction}")
    when /^archived/
      order("tenancies.archived #{direction}")
    when /^total_arrears_/
      order("total_arrears #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :in_arrears, -> {
    select('tenancies.*').where(booking_status: 2).where(archived: false).joins(:tenancy_payment_items)
    .select('SUM(CAST(NULLIF(tenancy_payment_items.arrears, \'\') AS DECIMAL(10,2))) AS total_arrears')
    .having('SUM(CAST(NULLIF(tenancy_payment_items.arrears, \'\') AS DECIMAL(10,2))) > 0')
    .group(:id)
  }

  after_save :check_booking_status?
  after_save :create_payment_items, if: -> { !archived? }
  after_create_commit :send_tenancy_dashboard_link, unless: :skip_sending_dashboard_link
  # after_update :change_the_booking_status, if: :archived?
  after_save :send_email_to_tenancy, if: -> { saved_change_to_booking_status? && complete? }
  before_create :set_booking_status
  before_create :generate_uri_string

  class << self
    def destroy_failed_to_book_tenancies_older_than(time)
      where('failed_to_book_at <= ?', DateTime.now - time).destroy_all
    end
  end

  def set_final_submission!
    transaction do
      update!(final_submission: true, final_submission_at: DateTime.now)
      competitors = Tenancy.competing_tenancies_for(self)
      competitors.update_all(failed_to_book_at: DateTime.now)
    end
  end

  def save_pdf_files
    [TenancyBookingPdf, TenancyAgreementPdf, TenancyDocumentPdf].map do |type|
      save_pdf(type.new(self))
    end.inject(:&)
  end

  ## Custom validation
  def read_doc_field
    if read_doc && read_doc != true && validate_doc
      errors.add(:read_doc, "Please agree to read")
    end
  end

  def confirm_tenancy_field
    if confirm_tenancy && confirm_tenancy != true && validate_doc
      errors.add(:confirm_tenancy, "Please agree to confirm")
    end
  end

  def accept_agreement_field
    if accept_agreement && accept_agreement != true && validate_doc
      errors.add(:accept_agreement, "Please accept the agreement")
    end
  end

  def emergency_details
    unless (is_guarantor_available || is_guarantor_available == "false")
      if validate_booking
        errors.add(:emergency_contact_name, "Please add emergency contact name") if emergency_contact_name.blank?
        errors.add(:emergency_contact_number, "Please add emergency contact number") if emergency_contact_number.blank?
        errors.add(:emergency_contact_postcode, "Please add emergency contact postcode") if emergency_contact_postcode.blank?
        errors.add(:emergency_contact_address, "Please add emergency contact address") if emergency_contact_address.blank?
      end
    end
  end

  def advance_rent_card_details
    if validate_booking
      errors.add(:payment_card_pan, "Please add payment card") if payment_card_pan.blank?
      errors.add(:payment_card_expiry, "Please add card expiry") if payment_card_expiry.blank?
      errors.add(:payment_card_cvc, "Please add valid cvv") if payment_card_cvc.blank?
      errors.add(:address, "Please add the address") if address.blank? # && tenant_is == 'Student'
    end
  end

  def tenancy_mobile
    errors.add(:mobile, "Mobile Can't blank") if validate_booking && mobile.blank?
  end

  def check_booking_status?
    room = self.room
    return unless room

    if (booking_status == 'complete')
      room.update_column(:availability, false) if room.availability?
      # room.delete_right_move if room.property.right_move
      # room.delete_from_zoopla if room.property.zoopla
    else
      room.update_column(:availability, true) unless room.availability?
    end
  end

  def check_availability
    date = Date.today
    month = date.month
    year = date.strftime('%y').to_i
    cur_year = month > 9 ? (year + 1) : (year)
    year = month < 9 ? "#{year-1}/#{year}" : "#{year}/#{year+1}"
    tenancies = room.tenancies.where(year: year, booking_status: 2).where(
      'DATE(tenancy_end) > ?', ("31/08/#{cur_year.to_i}").to_date
    )
    max_date = tenancies.count > 0 ? tenancies.order('tenancy_end asc').last.tenancy_end : ''
    errors.add(:tenancy_start, "You can book the room after #{max_date.strftime('%d/%m/%Y')} ") if max_date.present? && max_date > tenancy_start
  end

  def self.options_for_sorted_by
    [
      ['Tenant Surname (A-Z)', 'surname_asc'],
      ['Tenant Surname (Z-A)', 'surname_desc'],
      ['Tenant Type (A-Z)', 'tenant_type_asc'],
      ['Tenant Type (Z-A)', 'tenant_type_desc'],
      ['Tenancy Start (Newest)', 'tenancy_start_asc'],
      ['Tenancy Start (Oldest)', 'tenancy_start_desc'],
      ['Tenant End (Newest)', 'tenancy_end_asc'],
      ['Tenant End (Oldest)', 'tenancy_end_desc']
    ]
  end

  def self.options_for_sorted_by_arrears_report
    [
      ['Tenant Surname (A-Z)', 'surname_asc'],
      ['Tenant Surname (Z-A)', 'surname_desc'],
      ['Arrears Value (Low - High)', 'total_arrears_asc'],
      ['Arrears Value (High - Low)', 'total_arrears_desc'],
      ['Year (Low - High)', 'year_asc'],
      ['Year (High - Low)', 'year_desc'],
      ['Archived (No)', 'archived_asc'],
      ['Archived (Yes)', 'archived_desc'],
      # ['Tenant Type (A-Z)', 'tenant_type_asc'],
      # ['Tenant Type (Z-A)', 'tenant_type_desc'],
      # ['Tenancy Start (Newest)', 'tenancy_start_asc'],
      # ['Tenancy Start (Oldest)', 'tenancy_start_desc'],
      # ['Tenant End (Newest)', 'tenancy_end_asc'],
      # ['Tenant End (Oldest)', 'tenancy_end_desc']
    ]
  end

  def tenancy_is_nice_name
    # if tenant_type == 0
    #   "Not set"
    # elsif tenant_type == 1
    #   "Student"
    # elsif tenant_type == 2
    #   "Graduate"
    # elsif tenant_type == 3
    #   "Professional"
    # elsif tenant_type == 4
    #   "Home"
    # elsif tenant_type == 5
    #   "Co-Living"
    # else
    #   "Unset"
    # end
    if tenancy_is == 0
      "Student"
    elsif tenancy_is == 1
      "Professional"
    else
      "Unset"
    end
  end

  def tenant_name
    (first_name == "") ? "#{email}" : "#{first_name} #{surname}"
  end

  def send_tenancy_dashboard_link
    return false unless self.update(dashboard_link_mail: true, dashboard_link_mail_at: Time.now, dashboard_link_mail_number_of_time: self.dashboard_link_mail_number_of_time.to_i + 1)

    TenancyMailer.send_dashboard_link(self.id).deliver_now
    true
  end

  def send_email_to_tenancy
    TenancyMailer.send_complete_status_mail(id).deliver_now
  end

  def create_payment_items
    if payment_edit.present? && payment_edit
      if tenancy_is == 0 && !deposit_term.blank? && advanced_rent_payment_amount.present? &&  !tenancy_payment_items.exists?(item_type: deposit_term, item_year: year)
        adv_pay = self.tenancy_payment_items.find_or_initialize_by(item: 'AvR', item_type: deposit_term, due_date: created_at)
        adv_pay.amount_due = advanced_rent_payment_amount.round(2)
        adv_pay.item_year = year
        adv_pay.save
      end
      ids = []
      if deposit_term == 'monthly'
        unless tenancy_payment_items.exists?(item_type: 'monthly', item_year: year, item: 'Rent')
          total_items = number_of_payments || number_of_months

          per_month_amount = payment_amount.present? ? payment_amount : total_amount_to_pay_after_adv / total_items.to_i
          current_date = "#{rent_due_date}/#{tenancy_start.month}/#{tenancy_start.year}"
          current_date = current_date.to_date rescue tenancy_start.to_date

          total_items.to_i.times do |t|
            month = current_date.month
            n_year = current_date.strftime('%y').to_i
            c_year = month < 9 ? "#{n_year-1}/#{n_year}" : "#{n_year}/#{n_year+1}"
            rent_pay = self.tenancy_payment_items.where.not(id: ids).find_or_initialize_by(item: 'Rent', item_type: 'monthly')
            rent_pay.amount_due = per_month_amount.to_f.round(2)
            rent_pay.due_date = current_date
            rent_pay.item_year = c_year
            rent_pay.save
            ids << rent_pay.id
            current_date += 1.month
          end
        end
      elsif deposit_term == "termly"
        unless tenancy_payment_items.exists?(item_type: 'termly', item_year: year, item: 'Rent')
          due_dates = []
          if term_due_dates.blank? && self.tenancy_payment_items.present?
            due_dates = self.tenancy_payment_items.where(item: 'Rent', item_type: 'termly').order('due_date asc').pluck(:due_date)
          end
          termly_amount = payment_amount.present? ? payment_amount : total_amount_to_pay_after_adv / rent_installment_term.to_i
          (1..rent_installment_term.to_i).each do |j|
            date = term_due_dates.present? ? (term_due_dates["due_date_#{j}(3i)"] + "/" + term_due_dates["due_date_#{j}(2i)"] + "/" + term_due_dates["due_date_#{j}(1i)"]) : due_dates[j-1]
            date = date.to_date
            month = date.month
            n_year = date.strftime('%y').to_i
            c_year = month < 9 ? "#{n_year-1}/#{n_year}" : "#{n_year}/#{n_year+1}"
            rent_pay = self.tenancy_payment_items.where.not(id: ids).find_or_initialize_by(item: 'Rent', item_type: 'termly')
            rent_pay.due_date = date
            rent_pay.item_year = c_year
            rent_pay.amount_due = termly_amount.to_f.round(2)
            rent_pay.save
            ids << rent_pay.id
          end
        end
      elsif deposit_term == "full"
        unless tenancy_payment_items.exists?(item_type: 'full', item_year: year, item: 'Rent').present?

          fifty_percent_of_total_amount = payment_amount.present? ? payment_amount : total_amount_to_pay_after_adv / 2
          selected_date = Date.strptime(self.year.split('/')[0],"%y").year.to_s+self.tenancy_start.strftime("-%m-%d")
          next_due_date = selected_date.to_date
          2.times do |t|
            date = next_due_date
            month = date.month
            n_year = date.strftime('%y').to_i
            c_year = month < 9 ? "#{n_year-1}/#{n_year}" : "#{n_year}/#{n_year+1}"
            rent_pay = self.tenancy_payment_items.where.not(id: ids).find_or_initialize_by(item: 'Rent', item_type: 'full')
            rent_pay.due_date = next_due_date
            rent_pay.item_year = year
            rent_pay.amount_due = fifty_percent_of_total_amount.to_f.round(2)
            rent_pay.save
            ids << rent_pay.id
            next_due_date = next_due_date + 1.month
          end
        end
      end
    end
  end

  def update_deposit_term
    if self.rent_payment_option == 0 || self.rent_payment_option == "0"
      self.update_column(:deposit_term, "termly")
    elsif self.rent_payment_option == 1 || self.rent_payment_option == "1"
      self.update_column(:deposit_term, "monthly")
    elsif self.rent_payment_option == 2 || self.rent_payment_option == "2"
      self.update_column(:deposit_term, "full")
    end
  end

  def full_address
    tenancy_address = "#{address} #{city} #{state} #{post_code}"
    tenancy_address = "N/A" if tenancy_address.blank?
    tenancy_address
  end

  def roll_payment_into_next_year(last_year)
    tenancy_payment_items = self.tenancy_payment_items.where(item: 'Rent', item_year: last_year)
    tenancy_payment_items.order('due_date asc').each do |payment|
      self.tenancy_payment_items.create(item: 'Rent', item_year: year, due_date: (payment.due_date + 1.year), amount_due: payment.amount_due, item_type: payment.item_type)
    end
  end

  def set_booking_status
    return unless tenancy_end

    self.booking_status = 'booking' if tenancy_end >= Date.today
  end

  def generate_uri_string
    self.uri_string = SecureRandom.urlsafe_base64(nil, false)
  end

  private

  def save_pdf(pdf_instance)
    return false if tenancy_documents.where(document_name: TenancyDocument::PDF_DOCUMENT_NAMES[pdf_instance.class.name]).any?

    file = StringIO.new(pdf_instance.render)
    file.class.class_eval { attr_accessor :original_filename, :content_type } # add attr's that paperclip needs
    file.original_filename = TenancyDocument::PDF_FILE_NAMES[pdf_instance.class.name]
    file.content_type = "application/pdf"
    doc = tenancy_documents.new(document_name: TenancyDocument::PDF_DOCUMENT_NAMES[pdf_instance.class.name])
    doc.document_file = file
    doc.save
  end

  def total_amount_to_pay
    if self.tenancy_is == 0
      per_period_cost = self.weekly_price
      number_of_periods = self.number_of_weeks
    else
      per_period_cost = monthly_price
      number_of_periods = number_of_months
    end
    output = per_period_cost.to_f * number_of_periods.to_f
  end

  def total_amount_to_pay_after_adv
    adv = tenancy_is == 0 ? self.advanced_rent_payment_amount : 0
    total_amount_to_pay.to_f - adv.to_f
  end
end

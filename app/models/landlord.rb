class Landlord < ApplicationRecord
  mount_base64_uploader :landlord_signature, AttachmentUploader, file_name: -> (l) { "landlord-sig-"+l.id.to_s }

  ##
  enum partnership_format: ['Complete Partner', 'Support Partner', 'Tenancy Partner', 'Booking Partner','Listing Partner', 'Owned']
  validates :contact_name, presence: true
  validates :email, presence: true
  validates :partnership_format, presence: true

  has_many :properties, dependent: :destroy
  has_many :rooms, through: :properties, dependent: :destroy
  has_many :tenancies, through: :rooms
  has_many :reports
  has_many :landlord_documents, dependent: :destroy
  accepts_nested_attributes_for :landlord_documents, reject_if: :all_blank, allow_destroy: true

  has_many :landlord_staff_conversations
  has_many :sender_landlord_staff_messages, as: :sender, class_name: 'LandlordStaffMessage'
  has_many :receiver_landlord_staff_messages, as: :receiver, class_name: 'LandlordStaffMessage'


  filterrific(
    default_filter_params: { sorted_by: 'contact_name_asc' },
    available_filters: [
      :sorted_by,
      :search_query
    ]
  )

  terms_query = "LOWER(landlords.contact_name) LIKE ? OR LOWER(landlords.company_name) LIKE ?"
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
    when /^contact_name/
      order("landlords.contact_name #{direction}")
    when /^partner_type/
      order("landlords.partnership_format #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
      ['Contact Name (A-Z)', 'contact_name_asc'],
      ['Contact Name (Z-A)', 'contact_name_desc'],
      ['Partner Type (A-Z)', 'partner_type_asc'],
      ['Partner Type (Z-A)', 'partner_type_desc']
    ]
  end

  def landlord_name
    if company_name != ''
      company_name
    else
      contact_name
    end
  end

end

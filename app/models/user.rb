class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  devise :database_authenticatable, :authentication_keys => [:username]

  validates :email, uniqueness: true
  validates :username, uniqueness: true
  validates :colour, uniqueness: { allow_blank: true }

  has_many :event_users
  has_many :events, through: :event_users
  has_one_attached :avatar
  # validates :avatar, attached: true, content_type: ['image/png', 'image/jpg', 'image/jpeg'],
  #           dimension: { width: { min: 150, max: 600 },
  #                        height: { min: 150, max: 600 }, message: 'Image should be square and no larger than 600 px' }
  # has_many :attachments, as: :attached_item, dependent: :destroy

  has_many :tenancy_identifications, class_name: 'TenancyIdentification', foreign_key: 'staff_id'
  has_many :custom_property_reports, foreign_key: :run_by_id
  has_many :sender_tenancy_staff_messages, as: :sender, class_name: 'TenancyStaffMessage'
  has_many :receiver_tenancy_staff_messages, as: :receiver, class_name: 'TenancyStaffMessage'
  has_many :sender_landlord_staff_messages, as: :sender, class_name: 'LandlordStaffMessage'
  has_many :receiver_landlord_staff_messages, as: :receiver, class_name: 'LandlordStaffMessage'
  has_many :property_listing_locations

  #has_many :events
 # has_and_belongs_to_many :events
  scope :agent, -> { where(role: 'Agent') }
  scope :finance, -> { where(role: 'Finance') }
  filterrific(
      default_filter_params: { sorted_by: 'created_at_desc' },
      available_filters: [
          :sorted_by,
          :search_query
      ]
  )

  scope :search_query, ->(query) {
    return nil  if query.blank?
    terms = query.downcase.split(/\s+/)
    terms = terms.map{|term| term.gsub(/\*$/, '')}.map{|term| "%#{term}%"}
    num_or_conditions = 2
    where(
      terms.map {  |term|
        # "LOWER(tenancies.first_name) LIKE ? OR LOWER(tenancies.surname) LIKE ? OR LOWER(tenancies.properties.street) LIKE ?"
        "LOWER(users.first_name) LIKE ? OR LOWER(users.surname) LIKE ?"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }
  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^first_name/
      order("LOWER(users.first_name) #{direction}")
    when /^surname/
      order("LOWER(users.surname) #{direction}")
    when /^created_at_/
      order("users.created_at #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
      ['User First Name (A-Z)', 'first_name_asc'],
      ['User First Name (Z-A)', 'first_name_desc'],
      ['User Surname (A-Z)', 'surname_asc'],
      ['User Surname (Z-A)', 'surname_desc'],
      ['Created at (Newest first)', 'created_at_desc'],
      ['Created at (Oldest first)', 'created_at_asc']
    ]
  end

  def full_name
    "#{first_name} #{surname}"
  end

  def is_admin?
    self.admin
  end
end

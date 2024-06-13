class Room < ApplicationRecord
  require 'open-uri'
  require 'net/http'
  require 'json'

  ## serialize

  serialize :rightmove_response, Hash
  serialize :zoopla_response, Hash
  serialize :on_the_market_response, Hash

  belongs_to :property
  has_many :tenancies
  validates :number, presence: true

  scope :available, -> { where(availability: true) }
  scope :last_room_having_list_price, -> { where.not(list_price: nil) }

  ## callbacks
  before_create :set_agent_ref

  def room_details
    "#{property.property_name} #{number} #{list_price}"
  end

  filterrific(
    default_filter_params: { sorted_by: 'address_asc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :room_availability,
      :with_room_ids
    ]
  )
  scope :room_availability, ->(query) {
    return Room.all if query.room_available == "0" && query.room_booked == "0" && query.room_complete == "0" && query.room_expired == "0"
    if (query.room_available == "1")
      booked_rooms_for_the_year_ids = Tenancy.where(year: query.search_by_year_range, booking_status: [1, 2]).pluck(:room_id)
      return Room.where.not(id: booked_rooms_for_the_year_ids)
    elsif (query.room_booked == "1")
      booked_rooms_for_the_year_ids = Tenancy.booking.where(year: query.search_by_year_range).pluck(:room_id)
      return Room.where(id: booked_rooms_for_the_year_ids)
    elsif (query.room_complete == "1")
      booked_rooms_for_the_year_ids = Tenancy.complete.where(year: query.search_by_year_range).pluck(:room_id)
      return Room.where(id: booked_rooms_for_the_year_ids)
    elsif (query.room_expired == "1")
      booked_rooms_for_the_year_ids = Tenancy.where(year: query.search_by_year_range, booking_status: 3).pluck(:room_id)
      return Room.where(id: booked_rooms_for_the_year_ids)
    else
      Room.all
    end
  }
  scope :search_query, ->(query) {
    return nil  if query.blank?
    if query.class == Integer || query.class == Float
      where(list_price: query.to_f).or(where(number: query.to_i))
    else
      num_or_conditions = 4
      terms = query.downcase.split(/\s+/)
      terms = terms.map{|term| term.gsub(/\*$/, '')}.map{|term| "%#{term}%"}
      where(
        terms.map {  |term|
          "LOWER(tenancies.first_name) LIKE ? OR LOWER(tenancies.surname) LIKE ? OR LOWER(tenancies.email) LIKE ? OR LOWER(properties.street) LIKE ?"
        }.join(' AND '),
        *terms.map { |e| [e] * num_or_conditions }.flatten
      ).left_joins(:property, :tenancies)
    end
  }
  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^list_price/
      order("rooms.list_price #{direction}")
    # when /^number/
    #   order("properties.street asc, rooms.number #{direction}")
    when /^bedrooms/
      order("properties.number_of_bedrooms #{direction}")
    when /^address/
      order("properties.street #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_room_ids, ->(query) {
    return nil  if query.blank?
    ids = query.class == Integer ? query : query.split(",")
    Room.where(id: ids)
  }

  def self.options_for_sorted_by
    [
      ['Address (A-Z)', 'address_asc'],
      ['Address (Z-A)', 'address_desc'],
      # ['Room No. (Low - High)', 'number_asc'],
      # ['Room No. (High - Low)', 'number_desc'],
      ['Bedrooms (Low - High)', 'bedrooms_asc'],
      ['Bedrooms (High - Low)', 'bedrooms_desc'],
      ['List Price (Low - High)', 'list_price_asc'],
      ['List Price (High - Low)', 'list_price_desc']
    ]
  end

  def set_agent_ref
    self.agent_ref = (0...8).map { (65 + rand(26)).chr }.join
  end

  ## Create property with Rightmove
  def create_rightmove
    `rake rightmove:create[#{self.id}]`
  end

  ## create property in zoopla
  def create_in_zoopla
    `rails zoopla:create[#{self.id}]`
  end

  # Delete rightmove property
  def delete_right_move
    `rake rightmove:delete[#{self.id}]`
  end

  # Delete from zoopla
  def delete_from_zoopla
    `rake zoopla:delete[#{self.id}]`
  end

  def self.to_jsn
    all.map do |room|
      property = room.property
      year = Date.today.strftime('%y').to_i
      if Date.today.month > 8
        this_year = "#{year}/#{year+1}"
        next_year = "#{year + 1}/#{year+2}"
      else
        this_year = "#{year-1}/#{year}"
        next_year = "#{year}/#{year + 1}"
      end
      completed_tenancies_by_year = room.tenancies.where(year: [this_year, next_year])
                                        .where(booking_status: 'complete')
                                        .group_by(&:year)
      this_year_available = completed_tenancies_by_year[this_year].blank?
      next_year_available = completed_tenancies_by_year[next_year].blank?
      current_tenancies = completed_tenancies_by_year[this_year].map do |tenancy|
        {
          # id: tenancy.id,
          end_date: tenancy.tenancy_end
        }
      end if completed_tenancies_by_year[this_year].present?
      {
        this_year_available: this_year_available,
        # available_at: this_year_available ? room.created_at.strftime('%d/%m/%Y') : 'Not Available!',
        next_year_available: next_year_available,
        number: room.number,
        price: room.list_price,
        description: room.description,
        current_tenancies: current_tenancies
      }
    end
  end
end

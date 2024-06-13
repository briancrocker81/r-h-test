class Property < ApplicationRecord
  validates :landlord_id, presence: true
  validates :street, presence: true
  validates :postcode, presence: true

  belongs_to :landlord, optional: true
  has_many :rooms, dependent: :destroy
  has_many :tenancies, through: :rooms
  has_many :conversations
  has_many :viewings
  has_many :events, through: :viewings
  has_many :attachments, as: :attached_item, dependent: :destroy
  has_many_attached :image
  has_many :features, dependent: :destroy
  has_many :events_properties
  has_many :events, through: :events_properties
  has_many :tenancies, through: :rooms, dependent: :destroy
  has_many :compliance_documents, dependent: :destroy
  has_many :property_expenses, dependent: :destroy
  has_many :reports
  has_many :property_listing_locations, dependent: :destroy
  has_many :property_utilities, dependent: :destroy
  has_one :property_list_student, dependent: :destroy
  has_one :property_list_graduate, dependent: :destroy
  has_one :property_list_professional, dependent: :destroy
  has_one :property_list_family, dependent: :destroy
  accepts_nested_attributes_for :features, allow_destroy: true
  accepts_nested_attributes_for :compliance_documents, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: proc { |attributes| attributes[:attachment].nil? }
  accepts_nested_attributes_for :property_list_student, allow_destroy: true
  accepts_nested_attributes_for :property_list_graduate, allow_destroy: true
  accepts_nested_attributes_for :property_list_professional, allow_destroy: true
  accepts_nested_attributes_for :property_list_family, allow_destroy: true
  accepts_nested_attributes_for :property_listing_locations, allow_destroy: true
  accepts_nested_attributes_for :property_utilities, allow_destroy: true

  ## callbacks
  after_create_commit :create_rooms # Disable when seeding
  before_create :generate_listing_etag

  ## enum
  enum rental_type: %w(home room)

  serialize :property_type, Array

  def property_type_nice_name
    if property_status_type == 0
      'Student Year'
    elsif property_status_type == 1
      'Co Living'
    elsif property_status_type == 2
      event_name = 'Home'
    end
  end

  def email_tenants_compliance_documents!
    tenancies.where('Date(tenancy_start) <= ? and Date(tenancy_end) > ?', Date.today, Date.today)
             .where(booking_status: 'complete')
             .each do |tenancy|
      PropertyMailer.send_compliance_documents(id, tenancy.id).deliver_now
    end
  end

  class << self
    def combined_monthly_landlord_reports
      report_paths = []
      includes(:landlord, :property_expenses, rooms: :tenancies).uniq.each do |property|
        statements = property.reports.monthly.landlord_statement.where('DATE(created_at) between ? and ? and month = ?', Date.today.at_beginning_of_month, Date.today.at_end_of_month, Date.today.prev_month.month)
        report_paths += statements.map do |s|
          next unless s.report.present?

          Rails.env.development? ? s.report.path : s.report.url
        end.compact
      end

      pdf = CombinePDF.new
      if Rails.env.development?
        report_paths.each { |path| pdf << CombinePDF.load(path) }
      else
        report_paths.each { |path| pdf << CombinePDF.parse(Net::HTTP.get_response(URI.parse(path)).body) }
      end
      pdf
    end

    def generate_monthly_landlord_reports(regenerate: false)
      includes(:landlord, :property_expenses, rooms: :tenancies).uniq.each do |property|
        p "====#{property&.property_name}====="
        statements = property.reports.monthly.landlord_statement.where('DATE(created_at) between ? and ? and month = ?', Date.today.at_beginning_of_month, Date.today.at_end_of_month, Date.today.prev_month.month)
        if statements.count > 1
          puts "Skipping property #{property.id} as it has multiple landlord statements for this month"
          next
        end

        next if statements.count == 1 && !regenerate
        
        statements.destroy_all
        report = LandlordStatementReportPdf.new(property.id).render
        file = StringIO.new(report) #mimic a real upload file
        file.class.class_eval { attr_accessor :original_filename, :content_type } #add attr's that paperclip needs
        file.original_filename = "#{property&.property_name}.pdf"
        file.content_type = "application/pdf"
        date = Date.today
        year = date.strftime('%y').to_i
        month = date.strftime('%m').to_i
        statement_year = month < 9 ? "#{year - 1}/#{year}" : "#{year}/#{year + 1}"
        landlord_report = property.reports.new(report: file, landlord_id: property&.landlord&.id, year: statement_year, month: date.prev_month.month, report_type: 'landlord_statement', term_type: 'monthly')
        landlord_report.save
      end
    end
  end

  def property_name
    "#{number} #{street}"
  end


  filterrific(
    default_filter_params: { sorted_by: 'street_asc' },
    available_filters: [
      :sorted_by,
      :search_query
    ]
  )

  scope :search_query, ->(query) {
    return nil  if query.blank?
    query = query.to_s
    terms = query.downcase.split(/\s+/)
    terms = terms.map{|term| term.gsub(/\*$/, '')}.map{|term| "%#{term}%"}
    num_or_conditions = 3
    where(
      terms.map {  |term|
          "LOWER(properties.number) LIKE ? OR LOWER(properties.street) LIKE ? OR LOWER(properties.postcode) LIKE ?"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conditions }.flatten
    )
  }

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^street/
      order("LOWER(properties.street) #{direction}")
    when /^bedrooms/
      order("properties.number_of_bedrooms #{direction}")
    when /^postcode/
      order("LOWER(properties.postcode) #{direction}")
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
      ['Street (A-Z)', 'street_asc'],
      ['Street (Z-A)', 'street_desc'],
      ['Bedrooms (Low - High)', 'bedrooms_asc'],
      ['Bedrooms (High - Low)', 'bedrooms_desc'],
      ['Postcode (A-Z)', 'postcode_asc'],
      ['Postcode (Z-A)', 'postcode_desc']
    ]
  end

  ## create a rooms
  def create_rooms
    if rental_type == 'room' && !number_of_bedrooms.nil? && room_rental_price > 0.0
      price = room_rental_price.to_f
      number_of_bedrooms.to_i.times.each do |i|
        act_room = rooms.create(number: "#{i + 1}", list_price: price.round(2), ensuite: ensuite != 2)
      end
    else
      if home_rental_price > 0.0
        agent_ref = (0...8).map { (65 + rand(26)).chr }.join
        act_room = rooms.create(number: "Home", list_price: home_rental_price, ensuite: ensuite != 2, agent_ref: agent_ref)
      end
    end
  end

  ## generate listin etag for zoopla reference it chars should be in 1 to 250 length.
  def generate_listing_etag
    self.listing_etag = SecureRandom.hex(12)
  end

  ## get features
  def get_features_and_furnished
    features = []
    furnished = ''
    locality = ''
    council = ''
    property_types = property_type.reject(&:empty?)
    property_types.map.inspect do |p_type|
      case p_type
      when "Student"
        gen_property = property_list_student
        (1..6).each do |i|
          features << gen_property["additional_features_#{i}"]
        end
        furnished = nil if furnished.blank?
        locality = gen_property.location
        council = ''
      when "Professional"
        gen_property = property_list_professional
        (1..6).each do |i|
          features << gen_property["additional_features_#{i}"]
        end
        furnished = gen_property.furnished if furnished.blank?
        locality = gen_property.location
        council = gen_property.council_tax_band
      when "Family"
        gen_property = property_list_family
        (1..6).each do |i|
          features << gen_property["additional_features_#{i}"]
        end
        furnished = gen_property.furnished if furnished.blank?
        locality = gen_property.location
        council = gen_property.council_tax_band
      when "Graduate"
        gen_property = property_list_graduate
        (1..6).each do |i|
          features << gen_property["additional_features_#{i}"]
        end
        furnished = gen_property.furnished if furnished.blank?
        locality = gen_property.location
        council = gen_property.council_tax_band
      end
    end
    features = features.collect(&:strip)
    return {furnished: (furnished.nil? ? 2 : furnished) , features: features.reject(&:blank?), locality: locality, council: council}
  end

  ## zoopla display address
  def display_address
    str = "0"
    str = "#{number.to_s.strip}" if number
    str += ", #{street.to_s.strip}" if street.present?
    str += ", #{address_line_2.to_s.strip}" if address_line_2.present?
    str += ", #{city.present? ? city.to_s.strip : 'Plymouth'}"
    return str.strip.chomp(',')
  end

  def is_furnished(option)
    case option
    when 0 then 'All'
    when 1 then 'Some'
    when 2 then 'None'
    else 'Undefined'
    end
  end

  def build_listing_locations
    %w[website].each do |listing_type|
      ['23/24', '24/25'].each do |year|
        property_listing_locations.build(listing_type: listing_type, year: year) unless property_listing_locations.find_by(listing_type: listing_type, year: year)
      end
    end
  end

  def build_service_utilities
    PropertyUtility::SERVICE_AND_UTILITIES.each do |utility_name|
      property_utilities.build(utility_name: utility_name) unless property_utilities.find_by(utility_name: utility_name)
    end
  end

  def self.to_jsn
    with_includes = includes(:property_listing_locations, :attachments, rooms: :tenancies)
    with_includes
      .where(property_listing_locations: { listing_type: 'website', year: '23/24' })
      .or(
        with_includes.where(property_listing_locations: { listing_type: 'website', year: '24/25'})
      ).or(
      with_includes.where(list_on_3rd_party_websites: true)
    ).map do |property|
      property_types = property.property_type.reject(&:empty?)
      property_list = {}
      property_types.map.inspect do |p_type|
        property_list[p_type] = {}
        case p_type
        when "Student"
          property_list[p_type] = property.property_list_student.attributes
        when "Professional"
          property_list[p_type] = property.property_list_professional.attributes
        when "Family"
          property_list[p_type] = property.property_list_family.attributes
        when "Graduate"
          property_list[p_type] = property.property_list_graduate.attributes
        end
      end
      year = Date.today.strftime('%y').to_i
      if Date.today.month > 8
        this_year = "#{year}/#{year+1}"
        next_year = "#{year + 1}/#{year+2}"
      else
        this_year = "#{year-1}/#{year}"
        next_year = "#{year}/#{year + 1}"
      end
      if property.rental_type == 1
        rental_price = property.room_rental_price
      else
        rental_price = property.home_rental_price
      end

      def furniture(option)
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
      room_json = property.rooms.to_jsn
      available_rooms_this_yr = room_json.count { |json| json[:this_year_available] }
      available_rooms_next_yr = room_json.count { |json| json[:next_year_available] }

      listed = property.property_listing_locations.map do |item|
        if item.listing_type == 'website' && item.year == '23/24'
          {
            list_on: item.listing_type,
            year: item.year,
            available_rooms_this_year: available_rooms_this_yr,
            listed_this_year: true
          }
        elsif item.listing_type == 'website' && item.year == '24/25'
          {
            list_on: item.listing_type,
            year: item.year,
            available_rooms_next_year: available_rooms_next_yr,
            listed_next_year: true
          }
        else
          {
            list_on: item.listing_type,
            year: item.year,
          }
        end
      end
      listed.sort_by {|k| k.values_at('year', 'list_on') }
      listed.to_json

      list_this_year = 0
      list_next_year = 0

      utilities = property.property_utilities.where(included: true).each do |utility|
        utility.utility_name
      end

      listed.sort_by {|k| k.values_at('year', 'list_on') }
      listed.to_json


      property.property_listing_locations.map do |item|
        if item.listing_type == 'website' && item.year == '23/24'
          list_this_year = 1
        elsif item.listing_type == 'website' && item.year == '24/25'
          list_next_year = 1
        end
      end

      if !property.property_list_student&.list_price.nil?
        student_active =
            {
              front_photo: property.property_list_student&.front_photo,
              description: property.property_list_student&.description,
              list_price: property.property_list_student&.list_price,
              list_weekly: property.property_list_student&.list_weekly,
              list_monthly: property.property_list_student&.list_monthly,
              let_available_date: property.property_list_student&.let_available_date,
              deposit: property.property_list_student&.deposit,
              minimum_term: property.property_list_student&.minimum_term,
              location: property.property_list_student&.location,
              college: property.property_list_student&.college,
              style: property.property_list_student&.style,
              walk_to_city_campus: property.property_list_student&.walk_to_city_campus,
              additional_features_1: property.property_list_student&.additional_features_1,
              additional_features_2: property.property_list_student&.additional_features_2,
              additional_features_3: property.property_list_student&.additional_features_3,
              additional_features_4: property.property_list_student&.additional_features_4,
              additional_features_5: property.property_list_student&.additional_features_5,
              additional_features_6: property.property_list_student&.additional_features_6
            }
      else
        student_active = nil
      end

      if !property.property_list_graduate&.list_price.nil?
        graduate_active =
            {
              front_photo: property.property_list_graduate&.front_photo,
              list_price: property.property_list_graduate&.list_price,
              list_weekly: property.property_list_graduate&.list_weekly,
              list_monthly: property.property_list_graduate&.list_monthly,
              let_available_date: property.property_list_graduate&.let_available_date,
              deposit: property.property_list_graduate&.deposit,
              minimum_term: property.property_list_graduate&.minimum_term,
              description: property.property_list_graduate&.description,
              location: property.property_list_graduate&.location,
              # furnished: property.property_list_graduate&.furnished_type,
              student_allowed: property.property_list_graduate&.student_allowed,
              bus_route: property.property_list_graduate&.bus_route,
              additional_features_1: property.property_list_graduate&.additional_features_1,
              additional_features_2: property.property_list_graduate&.additional_features_2,
              additional_features_3: property.property_list_graduate&.additional_features_3,
              additional_features_4: property.property_list_graduate&.additional_features_4,
              additional_features_5: property.property_list_graduate&.additional_features_5,
              additional_features_6: property.property_list_graduate&.additional_features_6
            }
      else
        graduate_active = nil
      end

      if !property.property_list_professional&.list_price.nil?
        professional_active =
          {
            front_photo: property.property_list_professional&.front_photo,
            list_price: property.property_list_professional&.list_price,
            list_weekly: property.property_list_professional&.list_weekly,
            list_monthly: property.property_list_professional&.list_monthly,
            let_available_date: property.property_list_professional&.let_available_date,
            deposit: property.property_list_professional&.deposit,
            minimum_term: property.property_list_professional&.minimum_term,
            description: property.property_list_professional&.description,
            location: property.property_list_professional&.location,
            # furnished: property.property_list_professional&.furnished_type,
            council_tax_included: property.property_list_professional&.council_tax_included,
            bus_route: property.property_list_professional&.bus_route,
            additional_features_1: property.property_list_professional&.additional_features_1,
            additional_features_2: property.property_list_professional&.additional_features_2,
            additional_features_3: property.property_list_professional&.additional_features_3,
            additional_features_4: property.property_list_professional&.additional_features_4,
            additional_features_5: property.property_list_professional&.additional_features_5,
            additional_features_6: property.property_list_professional&.additional_features_6
          }
      else
        professional_active = nil
      end

      if !property.property_list_family&.list_price.nil?
        family_active =
          {
            front_photo: property.property_list_family&.front_photo,
            list_price: property.property_list_family&.list_price,
            list_weekly: property.property_list_family&.list_weekly,
            list_monthly: property.property_list_family&.list_monthly,
            let_available_date: property.property_list_family&.let_available_date,
            deposit: property.property_list_family&.deposit,
            minimum_term: property.property_list_family&.minimum_term,
            description: property.property_list_family&.description,
            location: property.property_list_family&.location,
            school: property.property_list_family&.school,
            park: property.property_list_family&.nearest_park_and_play_area,
            # furnished: property.property_list_family&.furnished_type,
            area_location: property.property_list_family&.area_family_location,
            additional_features_1: property.property_list_family&.additional_features_1,
            additional_features_2: property.property_list_family&.additional_features_2,
            additional_features_3: property.property_list_family&.additional_features_3,
            additional_features_4: property.property_list_family&.additional_features_4,
            additional_features_5: property.property_list_family&.additional_features_5,
            additional_features_6: property.property_list_family&.additional_features_6
          }
      else
        family_active = nil
      end


      # if ( list_this_year != 0 && list_next_year != 0 ) || property.list_on_3rd_party_websites == true
        {
        id: property.id,
        number: property.number,
        street: property.street,
        address_line_2: property.address_line_2,
        city: property.city,
        county: property.county,
        postcode: property.postcode,
        images: property.attachments.to_jsn,
        floorplans: nil,
        list_on: listed,
        list_externally: property.list_on_3rd_party_websites,
        listed_this_year: list_this_year,
        listed_next_year: list_next_year,
        property_type: property.property_type,
        property_style: property.style,
        number_of_bedrooms: property.number_of_bedrooms, number_of_bathrooms: property.number_of_bathrooms,
        number_of_kitchens: property.number_of_kitchens, number_of_gardens: property.number_of_gardens,
        number_of_lounges: property.number_of_lounges, number_of_studies: property.number_of_studies,
        number_of_dining_rooms: property.number_of_dining_rooms, number_of_utility_rooms: property.number_of_utility_rooms,
        number_of_toilets: property.number_of_toilets, number_of_studio_apartments: property.number_of_studio_apartments,
        number_of_showers: property.number_of_showers, other: property.other,
        listing_type: property.rental_type,
        ensuite: property.ensuite,
        available_rooms_this_year: available_rooms_this_yr,
        available_rooms_next_year: available_rooms_next_yr,
        rooms: property.rooms.to_jsn,
        pets: property.pets,
        parking: property.parking,
        outside_space: property.outside_space,
        council_tax_band: property.council_tax_band,
        epc_rating: property.epc_rating,
        furnished: property.furnished,
        utilities: utilities,
        "Students":[
          student_active
        ],
        "Graduates":[
          graduate_active
        ],
        "Professionals":[
          professional_active
        ],
        "Families":[
          family_active
        ],
      }
      # end
    end
  end
end

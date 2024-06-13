## rails zoopla:listing
require 'open-uri'
require 'net/http'
require 'json'
namespace :zoopla do
  desc 'listing the room from zoopla'
  task listing: :environment do
    uri = URI.parse("#{Rails.application.credentials.zoopla[:sanbox_url]}#{Rails.application.credentials.zoopla[:listing]}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.key =  OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/citylets.pem"))
    http.cert = OpenSSL::X509::Certificate.new(File.read("#{Rails.root}/zpg_realtime_listings_1624020518758319_20210618-20310616.crt"))
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => "application/json;profile=#{Rails.application.credentials.zoopla[:listing_profile]}",'Accept' => 'application/json')
    body = branch
    request.body = body
    response = http.request(request)
    p response.body
    puts '=============='
  end

  desc 'Create a room in zoopla'
  task :create, [:room_id] => :environment do |t, args|
    room = Room.find_by(id: args.room_id)
    begin
      if room.present?
        uri = URI.parse("#{Rails.application.credentials.zoopla[:sanbox_url]}#{Rails.application.credentials.zoopla[:listing_update]}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.key =  OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/citylets.pem"))
        http.cert = OpenSSL::X509::Certificate.new(File.read("#{Rails.root}/zpg_realtime_listings_1624020518758319_20210618-20310616.crt"))
        request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => "application/json;profile=#{Rails.application.credentials.zoopla[:listing_update_profile]}",'Accept' => 'application/json')
        body = zoopla_add_property_json(room)
        puts '============'
        request['ZPG-Listing-ETag'] = room.property.listing_etag
        request.body = body
        response = http.request(request)
        room.zoopla_response['create'] = response.body
        room.save(validate: false)
      end
    rescue Exception => e
      puts e.message
      room.zoopla_response['create_error'] = e.message
      room.update(validate: false)
    end
  end

  desc 'Delete a room from zoopla'
  task :delete, [:room_id] => :environment do |t, args|
    room = Room.find_by(id: args.room_id)
    begin
      if room.present?
        uri = URI.parse("#{Rails.application.credentials.zoopla[:sanbox_url]}#{Rails.application.credentials.zoopla[:listing_delete]}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.key =  OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/citylets.pem"))
        http.cert = OpenSSL::X509::Certificate.new(File.read("#{Rails.root}/zpg_realtime_listings_1624020518758319_20210618-20310616.crt"))
        request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => "application/json;profile=#{Rails.application.credentials.zoopla[:listing_delete_profile]}",'Accept' => 'application/json')
        body = zoopla_delete_property_json(room)
        request.body = body
        response = http.request(request)
        room.zoopla_response['delete'] = response.body
        room.save(validate: false)
      end
    rescue Exception => e
      puts e.message
      room.zoopla_response['delete_error'] = e.message
      room.update(validate: false)
    end
  end

  task branch_update: :environment do
    uri = URI.parse("#{Rails.application.credentials.zoopla[:sanbox_url]}#{Rails.application.credentials.zoopla[:branch_update]}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.key =  OpenSSL::PKey::RSA.new(File.read("#{Rails.root}/citylets.pem"))
    http.cert = OpenSSL::X509::Certificate.new(File.read("#{Rails.root}/zpg_realtime_listings_1624020518758319_20210618-20310616.crt"))
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => "application/json;profile=#{Rails.application.credentials.zoopla[:branch_update_profile]}",'Accept' => 'application/json')
    body = branch_update
    request.body = body
    response = http.request(request)
    p response.body
    puts '=============='
  end

end

## branch json
def branch
  { "branch_reference": "#{Rails.application.credentials.zoopla[:branch_id]}" }.to_json
end

def branch_update
  {
    "branch_reference": "#{Rails.application.credentials.zoopla[:branch_id]}",
    "branch_name": "Citylets Test Branch",
    "location": {
      "street_name": "Beechwood House Beech Avenue",
      "town_or_city": "Plymouth",
      "postal_code": "PL4 0QA",
      "country_code": "GB"
    },
    "email": "info@cityletsplymouth.co.uk",
    "website": "https://www.cityletsplymouth.co.uk/"
  }.to_json
end

## add property in zoopla
def zoopla_add_property_json(room)
  property = room.property
  feature_and_furnished = property.get_features_and_furnished
  hash_parking = {"0" => 'private', "1" => 'off street', "2" => 'permit', "3" => 'nearby', "4" => 'none'}
  hash_outside = {"0" => 'garden', "1" => 'yard', "2" => 'outside space', "3" => 'none' }
  items = []
  property_type = ['barn_conversion', 'block_of_flats', 'bungalow', 'business_park', 'chalet', 'chateau', 'cottage', 'country_house', 'detached', 'detached_bungalow', 'end_terrace', 'equestrian', 'farm', 'farmhouse', 'finca', 'flat', 'hotel', 'houseboat', 'industrial', 'land', 'leisure', 'light_industrial', 'link_detached', 'lodge', 'longere', 'maisonette', 'mews', 'office', 'park_home', 'parking', 'pub_bar', 'restaurant', 'retail', 'riad', 'semi_detached', 'semi_detached_bungalow', 'studio', 'terraced', 'terraced_bungalow', 'town_house', 'villa', 'warehouse']
  if property_type.include?(property.style.to_s.parameterize.underscore)
    p_type = property.style.to_s.parameterize.underscore
  else
    p_type = property.rental_type == "room" ? "flat" : "terraced"
    property.update_column(:style, p_type.titleize) if property.style.blank?
  end
  property.attachments.each do | att|
    items << {
      "type": 'image',
      "url": att.url,
      "caption": att.title
    } if att.url.present?
  end
  json_body = {
    "branch_reference": "#{Rails.application.credentials.zoopla[:branch_id]}",
    "category": "residential",
    "listing_reference": room.agent_ref,
    "location": {
      "property_number_or_name": property.number.present? ? property.number.to_s.strip : "0",
      "street_name": property.street.to_s.strip.chomp(','),
      "town_or_city": property.city.present? ? property.city.to_s.strip : 'Plymouth',
      "postal_code": property.postcode.to_s.strip.upcase,
      "country_code": "GB"
    },
    "pricing": {
      "rent_frequency": "per_week",
      "currency_code": "GBP",
      "price": "#{room.list_price}".to_i,
      "transaction_type": "rent"
    },
    "property_type": p_type,
    "available_from_date": property.created_at.strftime("%Y-%m-%d"),
    "bathrooms": property.number_of_bathrooms.to_i,
    "detailed_description": [
      {
        "text": property.other.present? ? property.other : room.description.present? ? room.description : 'N/A'
      }
    ],
    "display_address": property.display_address,
    # "feature_list": feature_and_furnished[:features],
    "furnished_state": feature_and_furnished[:furnished] ? "furnished" : "",
    "life_cycle_status": "available",
    "rental_term": "short_term",
    "total_bedrooms": property.number_of_bedrooms.to_i,
    # "available_bedrooms": property.number_of_bedrooms,
    # "council_tax_band": feature_and_furnished[:council].present? ? [feature_and_furnished[:council]] : [],
    # "outside_space": [hash_outside[property.outside_space.to_s]],
    # "parking": [hash_parking[property.parking.to_s]],
    "pets_allowed": property.pets.present?,
    # "tenanted": false,
    # "summary_description": property.other.to_s,
    "utility_room": property.number_of_utility_rooms.to_i > 0,
    "living_rooms": property.number_of_lounges.to_i,
  }
  json_body["summary_description"] = property.other.to_s if property.other.present?
  json_body['feature_list'] = feature_and_furnished[:features] if feature_and_furnished[:features].present?
  json_body["content"] = items if items.present?
  json_body[:location]["county"] = property.county if property.county.present?
  json_body[:location]['locality'] = feature_and_furnished[:locality] if feature_and_furnished[:locality].present?
  json_body.to_json
end

## remove property from zoopla
def zoopla_delete_property_json(room)
  {
    "listing_reference": room.agent_ref,
    "deletion_reason": 'let'
  }.to_json
end

# def validate_zoopla_value(val)
#   val.match(/^\S(|(.|\n)*\S)\Z/)
# end

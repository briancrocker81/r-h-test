## rails rightmove:create
require 'open-uri'
require 'net/http'
require 'json'
namespace :rightmove do
  desc 'Creat a room in the Rightmove'
  task :create, [:room_id] =>  :environment do |t, args|
    room = Room.find_by(id: args.room_id)
    begin
      if room
        uri = URI.parse(Rails.application.credentials.rightmove[:url] + Rails.application.credentials.rightmove[:send])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        p12 = OpenSSL::PKCS12::new(File.read(File.join(Rails.root, Rails.application.credentials.rightmove[:file])), Rails.application.credentials.rightmove[:password])
        http.cert = p12.certificate
        http.key = p12.key
        request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json','Accept' => 'application/json')

        ## manage body
        body = rightmove_create_body(room)
        request.body = body
        response = http.request(request)
        room.rightmove_response['create'] = response.body
        room.save(validate: false)
      end
    rescue Exception => e
      puts e.message
      room.rightmove_response['create_error'] = e.message
      room.save(validate: false)
    end
  end

  desc 'Delete a room from rightmove'
  task :delete, [:room_id] => :environment do |t, args|
    room = Room.find_by(id: args.room_id)
    begin
      if room.present?
        uri = URI.parse(Rails.application.credentials.rightmove[:url] + Rails.application.credentials.rightmove[:remove])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        p12 = OpenSSL::PKCS12::new(File.read(File.join(Rails.root, Rails.application.credentials.rightmove[:file])), Rails.application.credentials.rightmove[:password])
        http.cert = p12.certificate
        http.key = p12.key
        request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json','Accept' => 'application/json')

        body = rightmove_delete_body(room)
        request.body = body
        response = http.request(request)
        room.rightmove_response['delete'] = response.body
        room.save(validate: false)
      end
    rescue Exception => e
      puts e.message
      room.rightmove_response['delete_error'] = e.message
      room.save(validate: false)
    end
  end
end

def rightmove_create_body(room)
  property = room.property
  proprty_types = { "Apartment": 28, "House": 26, "Flat": 8, "Maisonette": 11, "Penthouse": 29, "Studio": 9, "Shared Flat": 49, "Bedsit": 0 }
  parkings = {"Off Street": 19, "Permit": 22, "Private": 23, "Neared": 21, "None": ''}
  hash_parking = {"0" => 'Private', "1" => 'Off street', "2" => 'Permit', "3" => 'Nearby', "4" => 'None'}
  hash_outside = {"0" => 'Garden', "1" => 'Yard', "2" => 'Outside space', "3" => 'None' }
  outside_spaces = { "Garden": [29, 30, 31, 32, 33, 34] , "Yard": [], "Outside space": []}
  property_data = property.get_features_and_furnished

  furnished = property_data[:furnished]
  property_furnished = furnished == 0 ? 0 : furnished == 1 ? 1 : furnished == 2 ? 0 : 2
  ## get needed data
  attachments = []
  room_photos = []
  postcode = property.postcode.to_s.delete(' ')
  postcode_1 = postcode[0..2]
  postcode_2 = postcode[3..-1]
  property.attachments.each do | att|
    single_attachment = {
      "media_type": 1,
      "media_url": att.attachment_url,
      "caption": att.title
    }
    room_photos << att.attachment_url
    attachments << single_attachment
  end

  return {
    "network": {
      "network_id": Rails.application.credentials.rightmove[:network_id]
    },
    "branch": {
      "branch_id": Rails.application.credentials.rightmove[:branch_id],
      "channel": 2,
      "overseas": false
    },
    "property": {
      "agent_ref": room.agent_ref,
      "published": true,
      "property_type": proprty_types[property.style.to_sym],
      "status": 6,
      "new_home": false,
      "create_date": DateTime.now.strftime('%d-%m-%Y %H:%M:%S'),
      "updated_date": DateTime.now.strftime('%d-%m-%Y %H:%M:%S'),
      "date_available": Date.today.strftime('%d-%m-%Y'),
      "student_property": property.property_type.include?("Student"),
      "house_flat_share": ( property.style == "Shared Flat" ? true : false),
      "let_type": 0,
      "address": {
        "house_name_number": property.property_name,
        "address_2": property.address_line_2,
        "town": property.city,
        "postcode_1": postcode_1,
        "postcode_2": postcode_2,
        "display_address":  "#{property.property_name} #{property.city} #{property.county}",
      },
      "price_information": {
        "price": room.list_price,
        "price_qualifier": 0,
        "deposit": 250,
        "administration_fee": 0,
      },
      "details": {
        "summary": property.other.present? ? property.other : "Beautiful, spacious",
        "description": property.other.present? ? property.other : "<p><span>This beautiful, spacious apartment, is situated in the stunning location . It has a light, sunny aspect with views over the this incredible city.<\/span><\/p>",
        "features": property_data[:features].count > 10 ? property_data[:features][0..9] : property_data[:features],
        "bedrooms": property.home? && property.number_of_bedrooms.present?  ? property.number_of_bedrooms : 1,
        "bathrooms": property.number_of_bathrooms ? property.number_of_bathrooms : 1,
        "parking": [parkings[hash_parking[property.parking.to_s].to_s.to_sym]],
        "pets_allowed": property.pets,
        "outside_space": outside_spaces[hash_outside[property.outside_space.to_s].to_s.to_sym],
        "furnished_type": property_furnished,
        "rooms": [
          {
            "room_name": "Room #{room.number}",
            "room_description": room.description.present? ? room.description : "<p><span>This beautiful, spacious apartment, is situated in the stunning location . It has a light, sunny aspect with views over the this incredible city.</span></p>",
            "room_dimension_unit": 5,
            "room_photo_urls": room_photos
          },
        ]
      },
      "media": attachments
    }
  }.to_json
end

def rightmove_delete_body(room)
  {
    "network":{
      "network_id": Rails.application.credentials.rightmove[:network_id]
    },
    "branch":{
      "branch_id": Rails.application.credentials.rightmove[:branch_id],
      "channel": "2"
    },
    "property":{
      "agent_ref": room.agent_ref,
    }
  }.to_json
end

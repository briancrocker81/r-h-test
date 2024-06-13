User.create!([
  {email: "briancrocker81@gmail.com", password: "Plymouth_1", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Brian", surname: "Crocker", username: "briancrocker", mobile: nil, admin: true, colour: "", role: "Staff"},
  {email: "james@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "James", surname: "Deacon", username: "jamesdeacon", mobile: "", admin: true, colour: "turquoise", role: "Agent"},
  {email: "paul@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Paul", surname: "Hewish", username: "paulhewish", mobile: nil, admin: true, colour: "orange", role: "Agent"},
  {email: "tom@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Tom", surname: "Body", username: "tombody", mobile: nil, admin: false, colour: "blue", role: "Agent"},
  {email: "jade@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Jade", surname: "Coller", username: "jadecoller", mobile: "", admin: true, colour: "", role: "Agent"},
  {email: "will@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Will", surname: "Body", username: "willbody", mobile: nil, admin: false, colour: "", role: "Staff"},
  {email: "emma@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Emma", surname: "Brockman", username: "emmabrokman", mobile: nil, admin: false, colour: "purple", role: "Agent"},
  {email: "debie@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Debbie", surname: "Wisdom", username: "debbiewisdom", mobile: nil, admin: false, colour: "", role: "Staff"},
  {email: "samantha@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Samantha", surname: "Pine", username: "samanthapine", mobile: nil, admin: false, colour: "", role: "Staff"},
  {email: "paulb@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Paul", surname: "Body", username: "paulbody", mobile: nil, admin: false, colour: "", role: "Staff"},
  {email: "lauren@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Lauren", surname: "Whittaker", username: "laurenwhittaker", mobile: nil, admin: false, colour: "", role: "Staff"},
  {email: "wendy@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Wendy", surname: "Body", username: "wendybody", mobile: nil, admin: false, colour: "", role: "Staff"},
  {email: "adele@cityletsplymouth.co.uk", password: "password", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, first_name: "Adele", surname: "Body", username: "adelebody", mobile: nil, admin: false, colour: "", role: "Staff"}
])

(1..20).each do |id|
  contact_name = Faker::Name.name
  Faker::Config.locale = 'en-GB'
  Landlord.create!(
    id: id,
    contact_name: contact_name,
    contact_number: Faker::PhoneNumber.cell_phone,
    email: Faker::Internet.email,
    address: Faker::Address.full_address,
    partnership_format: rand(1..4),
    pay_direct: 1,
    account_name: contact_name,
    bank_name: Faker::Bank.name,
    bank_address: Faker::Address.full_address,
    bank_account_number: Faker::Bank.account_number,
    iban: Faker::Bank.iban,
    bic: Faker::Bank.swift_bic
  )
end

(1..5).each do |id|
  rooms = rand(1..11)
  rent_type = rand(0..1)
  agent_ref = (0...8).map { (65 + rand(26)).chr }.join
  if rent_type == 0
    room_rental_price = Faker::Number.within(range: 90..200)
    room_base = room_rental_price * 0.9
  else
    home_rental_price = Faker::Number.within(range: 500..2000)
    home_base = home_rental_price * 0.9
  end
  Faker::Config.locale = 'en-GB'
  Property.create!(
    id: id,
    landlord_id: rand(1..20),
    number: Faker::Number.within(range: 1..100),
    street: Faker::Address.street_name,
    address_line_2: %w[Crownhill Mutley Barbican Estover Derriford].sample,
    city: "Plymouth",
    postcode: "PL#{Faker::Number.within(range: 1..21)} #{Faker::Number.within(range: 1..9)}#{Faker::Alphanumeric.alpha(number: 2).upcase}",
    number_of_bedrooms: rooms,
    property_type: %w[Student Graduate Professional Family].sample(rand(1..2)),
    rental_type: rent_type,
    number_of_bathrooms: rand(1..rooms),
    pets: Faker::Boolean.boolean(true_ratio: 0.2),
    home_rental_price: Faker::Number.within(range: 95..1500),
    parking: rand(0..4),
    outside_space: rand(0..3),
    council_tax_reference: "PL#{Faker::Alphanumeric.alpha(number: 6)}",
    style: %w[Apartment, Bedsit, Flat, House, Maisonette, Penthouse, Shared Flat, Studio].sample,
    number_of_kitchens: rand(1..rooms),
    number_of_gardens: rand(1..3),
    number_of_lounges: rand(1..rooms),
    number_of_studies: rand(1..rooms),
    number_of_dining_rooms: rand(1..rooms),
    number_of_utility_rooms: rand(1..rooms),
    number_of_toilets: rand(1..rooms),
    number_of_studio_apartments: rand(1..rooms),
    number_of_showers: rand(1..rooms),
    other: Faker::Lorem.paragraphs(number: 1, supplemental: true),
    list_on_website: 0
  )
  # if rent_type == 0
  #   rooms.to_i.times.each do |i|
  #     Room.create(number: "#{i + 1}", property_id: id, list_price: room_rental_price.round(2), ensuite: rand(0..1), agent_ref: agent_ref)
  #   end
  # else
  #   if home_rental_price > 0.0
  #     Room.create(number: "Home", property_id: id, list_price: home_rental_price, ensuite: rand(0..1), agent_ref: agent_ref)
  #   end
  # end
end

# (1..5).each do |id|
#   rooms = rand(1..11)
#   rent_type = rand(0..1)
#   agent_ref = (0...8).map { (65 + rand(26)).chr }.join
#   if rent_type == 0
#     room_rental_price = Faker::Number.within(range: 90..200)
#     room_base = room_rental_price * 0.9
#   else
#     home_rental_price = Faker::Number.within(range: 500..2000)
#     home_base = home_rental_price * 0.9
#   end
#   Faker::Config.locale = 'en-GB'
#   Tenancy.create!(
#     tenancy_start:
#     tenancy_end:
#     first_name:
#     surname:
#     dob:
#     mobile:
#     email:
#     nationality:
#     criminal_record:
#     accept_agreement:
#     year:
#     uri_string:
#     form_submitted:
#     signed_tenancy_agreement:
#     read_doc:
#     address:
#     state:
#     city:
#     post_code:
#     signatrue: 'https://camo.githubusercontent.com/fcd5a5ab2be5419d00fcb803f14c55652cf60696d7f6d9828b99c1783d9f14a3/68747470733a2f2f662e636c6f75642e6769746875622e636f6d2f6173736574732f393837332f3236383034362f39636564333435342d386566632d313165322d383136652d6139623137306135313030342e706e67',
#     signed_date_time:
#     final_submission:
#     tenant_type:
#     room_id:
#     is_guarantor_available:
#
#   )
# end
json.extract! room, :id, :number, :title, :description, :tenancy_start, :tenancy_end, :price, :property_id, :landlord_id, :created_at, :updated_at
json.url room_url(room, format: :json)

json.extract! tenancy, :id, :property_id, :tenancy_rate, :rate, :tenant_type, :tenancy_start, :tenancy_end, :first_name, :surname, :dob, :mobile, :email, :nationality, :criminal_record, :accept_agreement, :year, :status, :created_at, :updated_at
json.url tenancy_url(tenancy, format: :json)

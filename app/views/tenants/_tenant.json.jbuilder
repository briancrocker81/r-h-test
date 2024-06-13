json.extract! tenant, :id, :first_name, :surname, :dob, :mobile_number, :email, :nationality, :studying_at, :student_id_number, :course, :guarantor_name, :guarantor_address, :guarantor_post_code, :guarantor_email, :guarantor_mobile, :guarantor_relationship, :created_at, :updated_at
json.url tenant_url(tenant, format: :json)

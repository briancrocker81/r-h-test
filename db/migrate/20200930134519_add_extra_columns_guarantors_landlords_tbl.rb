class AddExtraColumnsGuarantorsLandlordsTbl < ActiveRecord::Migration[5.2]
  def change
    add_column :guarantors, :own_property, :boolean
    add_column :guarantors, :national_insurance_number, :string
    add_column :guarantors, :contact_number, :string
    add_column :guarantors, :date_of_birth, :date
    add_column :guarantors, :tenant_relationship, :string
    add_column :guarantors, :employment_status, :integer
    add_column :guarantors, :employer_name, :string
    add_column :guarantors, :employer_manager, :string
    add_column :guarantors, :employer_contact, :string
    add_column :guarantors, :employer_address, :text
    add_column :guarantors, :employer_email, :string
    add_column :guarantors, :job_title, :string
    add_column :guarantors, :net_salary, :string
    add_column :guarantors, :guarantor_signature, :string
    add_column :guarantors, :guarantor_signature_date, :date
    add_column :guarantors, :photo_id, :string
    add_column :guarantors, :utility_bill, :string
    add_column :guarantors, :uri_string, :text
    add_column :guarantors, :confirm_guarantor, :boolean, default: false
    
    #landlords
    add_column :landlords, :landlord_signature, :string 
    add_column :landlords, :landlord_signature_date, :date 
  end
end

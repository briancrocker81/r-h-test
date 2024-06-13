json.extract! company, :id, :name, :address, :phone_number, :main_email, :bank_account_name, :bank_name, :bank_address, :bank_sort_code, :bank_account_number, :bank_iban, :bank_bic, :vat_number, :registration_number, :main_contact, :created_at, :updated_at
json.url company_url(company, format: :json)

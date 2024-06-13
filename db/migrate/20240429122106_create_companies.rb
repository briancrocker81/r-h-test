class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.text :address
      t.string :phone_number
      t.string :main_email
      t.string :bank_account_name
      t.string :bank_name
      t.text :bank_address
      t.string :bank_sort_code
      t.string :bank_account_number
      t.string :bank_iban
      t.string :bank_bic
      t.string :vat_number
      t.string :registration_number
      t.string :main_contact

      t.timestamps
    end
  end
end

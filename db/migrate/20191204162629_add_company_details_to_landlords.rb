class AddCompanyDetailsToLandlords < ActiveRecord::Migration[5.2]
  def change
    add_column :landlords, :contact_name, :string
    add_column :landlords, :landlord_type, :boolean
    add_column :landlords, :company_name, :string
    add_column :landlords, :notes, :text
    add_column :landlords, :preferred_contact_method, :boolean

    remove_column :landlords, :title
    remove_column :landlords, :first_name
    remove_column :landlords, :surname
  end
end

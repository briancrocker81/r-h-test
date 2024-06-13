class AddColEmergencyDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :emergency_contact_address, :text
    add_column :tenancies, :emergency_contact_postcode, :string
  end
end

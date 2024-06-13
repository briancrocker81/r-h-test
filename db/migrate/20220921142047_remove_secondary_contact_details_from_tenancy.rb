class RemoveSecondaryContactDetailsFromTenancy < ActiveRecord::Migration[5.2]
  def change
    remove_column :tenancies, :secondary_contact_details
  end
end

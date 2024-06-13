class AddJsonColumnToTenancies < ActiveRecord::Migration[5.2]
  def change
  	add_column :tenancies, :secondary_contact_details, :json
  end
end

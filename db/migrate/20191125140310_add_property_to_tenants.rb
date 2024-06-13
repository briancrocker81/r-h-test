class AddPropertyToTenants < ActiveRecord::Migration[5.2]
  def change
  	add_reference :tenants, :property, index: true
  end
end

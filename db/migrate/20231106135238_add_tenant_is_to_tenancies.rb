class AddTenantIsToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :tenancy_is, :integer
  end
end

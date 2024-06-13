class ChangeTenantTypeToBeIntegerInTenancy < ActiveRecord::Migration[5.2]
  def change
    remove_column :tenancies, :tenant_type, :boolean
    add_column :tenancies, :tenant_type, :integer
  end
end

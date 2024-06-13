class DropTenantsTable < ActiveRecord::Migration[5.2]
  def change
    remove_reference :student_tenants, :tenant, index: true, foreign_key: true
    drop_table :tenants
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

class AlterTenancyTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :tenancies, :property_id
  end
end

class RemoveGenericOldFieldsFromProperty < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :date_available
    remove_column :properties, :length_of_tenancy
    remove_column :properties, :deposit_listing
  end
end

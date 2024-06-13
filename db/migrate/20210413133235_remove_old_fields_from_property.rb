class RemoveOldFieldsFromProperty < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :wifi, :string
    remove_column :properties, :bin_collection, :string
    remove_column :properties, :furnished, :integer
    remove_column :properties, :landlord_direct, :boolean
  end
end

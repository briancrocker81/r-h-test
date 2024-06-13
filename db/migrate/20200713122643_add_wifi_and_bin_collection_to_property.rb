class AddWifiAndBinCollectionToProperty < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :wifi, :string
    add_column :properties, :bin_collection, :string
  end
end

class AddListingChargesToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :deposit_listing, :string
    add_column :properties, :length_of_tenancy, :string
  end
end

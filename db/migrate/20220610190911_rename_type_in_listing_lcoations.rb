class RenameTypeInListingLcoations < ActiveRecord::Migration[5.2]
  def change
    rename_column :property_listing_locations, :type, :listing_type
  end
end

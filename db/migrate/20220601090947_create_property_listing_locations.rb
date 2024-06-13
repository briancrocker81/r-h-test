class CreatePropertyListingLocations < ActiveRecord::Migration[5.2]
  def change
    create_table :property_listing_locations do |t|
      t.integer :type
      t.string :year
      t.references :property, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

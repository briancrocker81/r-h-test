class CreatePropertyListFamilies < ActiveRecord::Migration[5.2]
  def change
    create_table :property_list_families do |t|
      t.references :property, foreign_key: true
      t.text :description
      t.string :location
      t.string :school
      t.text :nearest_park_and_play_area
      t.integer :furnished
      t.text :area_family_location
      t.string :council_tax_band
      t.string :front_photo
      t.text :additional_features
      t.timestamps
    end
  end
end

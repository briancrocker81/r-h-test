class CreatePropertyListProfessionals < ActiveRecord::Migration[5.2]
  def change
    create_table :property_list_professionals do |t|
      t.references :property, foreign_key: true
      t.text :description
      t.integer :furnished
      t.string :location
      t.string :council_tax_band
      t.text :bus_route
      t.string :front_photo
      t.text :additional_features
      t.timestamps
    end
  end
end

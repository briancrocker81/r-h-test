class CreatePropertyListGraduates < ActiveRecord::Migration[5.2]
  def change
    create_table :property_list_graduates do |t|
      t.references :property, foreign_key: true
      t.text :description
      t.string :location
      t.boolean :student_allowed, default: true
      t.integer :furnished
      t.string :council_tax_band
      t.string :front_photo
      t.text :additional_features
      t.text :bus_route
      t.timestamps
    end
  end
end

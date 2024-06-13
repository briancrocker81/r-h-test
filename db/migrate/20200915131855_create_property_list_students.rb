class CreatePropertyListStudents < ActiveRecord::Migration[5.2]
  def change
    create_table :property_list_students do |t|
      t.references :property, foreign_key: true
      t.text :description
      t.string :location
      t.string :college
      t.string :style
      t.boolean :pet_passport_allowed
      t.integer :walk_to_city_campus
      t.string :front_photo
      t.text :additional_features
      t.timestamps
    end
  end
end

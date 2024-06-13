class CreateProperties < ActiveRecord::Migration[5.1]
  def change
    create_table :properties do |t|
      t.string :number
      t.string :street
      t.string :address_line_2
      t.string :city
      t.string :county
      t.string :postcode, limit: 8
      t.integer :number_of_rooms, limit: 4
      t.string :property_type
      t.text :description
      t.string :location
      t.string :listing_type
      t.integer :furnished, limit: 2


      t.timestamps
    end
  end
end

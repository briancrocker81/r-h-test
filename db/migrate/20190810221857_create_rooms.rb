class CreateRooms < ActiveRecord::Migration[5.1]
  def change
    create_table :rooms do |t|
      t.string :number
      t.string :title
      t.text :description
      t.decimal :price
      t.string :dimensions
      t.references :property, foreign_key: true
      t.references :landlord, foreign_key: true

      t.timestamps
    end
  end
end

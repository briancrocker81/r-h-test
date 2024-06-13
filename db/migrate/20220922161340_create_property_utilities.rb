class CreatePropertyUtilities < ActiveRecord::Migration[5.2]
  def change
    create_table :property_utilities do |t|
      t.string :utility_name
      t.boolean :included
      t.decimal :landlord_contribution, precision: 6, scale: 2
      t.string :frequency
      t.references :property, foreign_key: true

      t.timestamps
    end
  end
end

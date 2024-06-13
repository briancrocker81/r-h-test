class CreateLandlords < ActiveRecord::Migration[5.1]
  def change
    create_table :landlords do |t|
      t.string :title, limit: 12
      t.string :first_name
      t.string :surname
      t.string :contact_number
      t.string :alternate_number
      t.string :email
      t.text :address

      t.timestamps
    end
  end
end

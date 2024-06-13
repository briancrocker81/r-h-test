class AddRoomRentalPriceIntoProperty < ActiveRecord::Migration[5.2]
  def up
    add_column :properties, :room_rental_price, :decimal, default: 0.0
    change_column :properties, :home_rental_price, :decimal, default: 0.0
  end

  def down
    remove_column :properties, :room_rental_price, :decimal, default: 0.0
    change_column :properties, :home_rental_price, :decimal
  end
end

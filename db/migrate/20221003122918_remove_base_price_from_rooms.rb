class RemoveBasePriceFromRooms < ActiveRecord::Migration[5.2]
  def change
    remove_column :rooms, :base_price
  end
end

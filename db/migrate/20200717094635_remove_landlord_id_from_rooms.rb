class RemoveLandlordIdFromRooms < ActiveRecord::Migration[5.2]
  def change
    remove_column :rooms, :landlord_id
  end
end

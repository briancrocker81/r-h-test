class AddAvailabilityRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :availability, :boolean, default: true
  end
end

class AddRoomsToTenancy < ActiveRecord::Migration[5.2]
  def change
    add_reference :tenancies, :room, index: true
  end
end

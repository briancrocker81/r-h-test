class AddRoomIdToTenants < ActiveRecord::Migration[5.2]
  def change
  	add_reference :tenants, :room, index: true
  end
end

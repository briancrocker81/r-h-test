class ChangeBookingStatusTypeToInteger < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :booked_status, :integer, default: 0
    add_index :tenancies, :booked_status
  end
end

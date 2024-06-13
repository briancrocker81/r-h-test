class AddSenderTypeAndReceiverTypeIntoLandlordStaffMessage < ActiveRecord::Migration[5.2]
  def up
    add_column :landlord_staff_messages, :sender_type, :string
    add_column :landlord_staff_messages, :receiver_type, :string
  end

  def down
    remove_column :landlord_staff_messages, :sender_type
    remove_column :landlord_staff_messages, :receiver_type
  end
end

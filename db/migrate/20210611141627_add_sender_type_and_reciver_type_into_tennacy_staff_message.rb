class AddSenderTypeAndReciverTypeIntoTennacyStaffMessage < ActiveRecord::Migration[5.2]
  def up
    add_column :tenancy_staff_messages, :sender_type, :string
    add_column :tenancy_staff_messages, :receiver_type, :string
  end

  def down
    remove_column :tenancy_staff_messages, :sender_type
    remove_column :tenancy_staff_messages, :receiver_type
  end
end

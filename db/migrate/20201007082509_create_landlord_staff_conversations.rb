class CreateLandlordStaffConversations < ActiveRecord::Migration[5.2]
  def change
    create_table :landlord_staff_conversations do |t|
      t.references :landlord, foreign_key: true
      t.timestamps
    end
  end
end

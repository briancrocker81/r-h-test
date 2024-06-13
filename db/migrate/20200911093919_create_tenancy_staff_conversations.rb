class CreateTenancyStaffConversations < ActiveRecord::Migration[5.2]
  def change
    create_table :tenancy_staff_conversations do |t|
      t.references :tenancy, foreign_key: true
      t.timestamps
    end
  end
end

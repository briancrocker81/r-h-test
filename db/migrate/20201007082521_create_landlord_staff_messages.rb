class CreateLandlordStaffMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :landlord_staff_messages do |t|
      t.text :body
      t.text :subject
      t.string :from
      t.references :landlord_staff_conversation, foreign_key: true
      t.integer :sender_id
      t.integer :receiver_id     
      t.boolean :read, default: false
      t.timestamps
    end
  end
end

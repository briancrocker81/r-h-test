class CreateConversations < ActiveRecord::Migration[5.2]
  def change
    create_table :conversations do |t|
      t.references :property, foreign_key: true
      t.timestamps
    end
  end
end

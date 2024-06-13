class CreateAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :attachments do |t|
      t.string  :title
      t.integer :attached_item_id
      t.string  :attached_item_type
      t.string  :attachment, null: false
      t.string  :original_filename
      t.string  :content_type
      t.timestamps
    end
    add_index "attachments", ["attached_item_type", "attached_item_id"]
  end
end

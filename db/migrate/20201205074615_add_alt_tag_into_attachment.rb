class AddAltTagIntoAttachment < ActiveRecord::Migration[5.2]
  def change
    add_column :attachments, :alt_tag, :string
    add_index :attachments, :alt_tag
  end
end

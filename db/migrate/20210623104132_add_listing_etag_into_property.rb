class AddListingEtagIntoProperty < ActiveRecord::Migration[5.2]
  def up
    add_column :properties, :listing_etag, :string
  end

  def down
    remove_column :properties, :listing_etag
  end
end

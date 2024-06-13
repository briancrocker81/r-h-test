class AddExternalListingOptionToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :list_on_3rd_party_websites, :boolean
  end
end

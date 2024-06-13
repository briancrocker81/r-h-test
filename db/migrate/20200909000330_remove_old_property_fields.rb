class RemoveOldPropertyFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :idea_tenant
    remove_column :properties, :transport_links
    remove_column :properties, :schools
    remove_column :properties, :website_description
    remove_column :properties, :list_on_rightmove
    remove_column :properties, :rightmove_description
    remove_column :properties, :list_on_zoopla
    remove_column :properties, :zoopla_description
    remove_column :properties, :location
    remove_column :properties, :council_tax_band
    remove_column :properties, :landlord_direct
    add_column :properties, :landlord_direct, :boolean
  end
end

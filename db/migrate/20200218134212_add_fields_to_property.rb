class AddFieldsToProperty < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :style, :string
    add_column :properties, :landlord_direct, :integer
    add_column :properties, :council_tax_band, :string
    add_column :properties, :parking, :string
    add_column :properties, :outside_space, :integer
    add_column :properties, :transport_links, :string
    add_column :properties, :schools, :string
  end
end

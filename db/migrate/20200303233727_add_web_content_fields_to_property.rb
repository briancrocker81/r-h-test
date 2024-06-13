class AddWebContentFieldsToProperty < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :website_description, :text
    add_column :properties, :rightmove_description, :text
    add_column :properties, :list_on_rightmove, :boolean
    add_column :properties, :zoopla_description, :text
    add_column :properties, :list_on_zoopla, :boolean
  end
end

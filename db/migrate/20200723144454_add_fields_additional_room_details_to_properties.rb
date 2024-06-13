class AddFieldsAdditionalRoomDetailsToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :number_of_kitchens, :integer
    add_column :properties, :number_of_gardens, :integer
    add_column :properties, :number_of_lounges, :integer
    add_column :properties, :number_of_studies, :integer
    add_column :properties, :number_of_dining_rooms, :integer
    add_column :properties, :number_of_utility_rooms, :integer
    add_column :properties, :number_of_toilets, :integer
    add_column :properties, :number_of_studio_apartments, :integer
    add_column :properties, :number_of_showers, :integer
    add_column :properties, :other, :text
  end
end

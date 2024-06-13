class AddMoreFieldsToProperty < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :number_of_bathrooms, :integer
    add_column :properties, :pets, :boolean
    add_column :properties, :tenancy_length, :string, array: true, default: '{}'
    add_column :properties, :idea_tenant, :string, array: true, default: '{}'
    add_column :properties, :currently_occupied, :boolean
    add_column :properties, :date_available, :date

    rename_column :properties, :number_of_rooms, :number_of_bedrooms

  end
end

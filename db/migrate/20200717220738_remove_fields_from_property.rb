class RemoveFieldsFromProperty < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :date_available
    remove_column :properties, :tenancy_length
    remove_column :properties, :next_available_date
  end
end

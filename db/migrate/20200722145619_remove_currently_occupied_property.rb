class RemoveCurrentlyOccupiedProperty < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :currently_occupied, :boolean
  end
end

class RemovePropertyIdFromEvents < ActiveRecord::Migration[5.2]
  def change
  	remove_column :events, :property_id
  end
end

class AddTenancyIdsIntoEvent < ActiveRecord::Migration[5.2]
  def up
    add_column :events, :tenancy_ids, :text
  end

  def down
    remove_column :events, :tenancy_ids
  end
end

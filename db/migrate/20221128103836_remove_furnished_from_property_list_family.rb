class RemoveFurnishedFromPropertyListFamily < ActiveRecord::Migration[5.2]
  def change
    remove_column :property_list_families, :furnished, :integer
  end
end

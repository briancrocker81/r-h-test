class RemoveFurnishedFromPropertyListGraduates < ActiveRecord::Migration[5.2]
  def change
    remove_column :property_list_graduates, :furnished, :integer
  end
end

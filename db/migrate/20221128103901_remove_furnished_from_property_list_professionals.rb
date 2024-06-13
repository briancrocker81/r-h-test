class RemoveFurnishedFromPropertyListProfessionals < ActiveRecord::Migration[5.2]
  def change
    remove_column :property_list_professionals, :furnished, :integer
  end
end

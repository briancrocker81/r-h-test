class RemoveDespUspFromProperties < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :description
  end
end

class ChangeColmunTypeProperties < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :parking, :string
    add_column :properties, :parking, :boolean
  end
end

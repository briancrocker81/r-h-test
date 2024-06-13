class AlterBooleanFieldsForProperties < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :parking
    add_column :properties, :parking, :integer
    remove_column :properties, :outside_space
    add_column :properties, :outside_space, :integer

    add_column :properties, :ensuite, :integer
  end
end

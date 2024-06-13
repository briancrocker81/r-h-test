class AlterRoomsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :ensuite, :boolean
    add_column :rooms, :base_price, :decimal

    rename_column :rooms, :price, :list_price

    remove_column :rooms, :title, :string
  end
end

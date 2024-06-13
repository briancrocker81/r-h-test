class AddSyncWithOntheMarketAndZopplaInProperty < ActiveRecord::Migration[5.2]
  def up
    add_column :properties, :on_the_market, :boolean, default: false
    add_column :properties, :zoopla, :boolean, default: false
    add_column :rooms, :zoopla_response, :text
    add_column :rooms, :on_the_market_response, :text
    change_column :rooms, :rightmove_response, :text
    add_index :properties, :on_the_market
    add_index :properties, :zoopla
    add_index :properties, :right_move
  end

  def down
    remove_index :properties, :right_move
    remove_index :properties, :on_the_market
    remove_index :properties, :zoopla
    remove_column :properties, :on_the_market
    remove_column :properties, :zoopla
  end
end

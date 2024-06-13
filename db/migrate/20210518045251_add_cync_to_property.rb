class AddCyncToProperty < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :right_move, :boolean, default: false
  end
end

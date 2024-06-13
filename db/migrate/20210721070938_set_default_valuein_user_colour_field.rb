class SetDefaultValueinUserColourField < ActiveRecord::Migration[5.2]
  def up
    change_column :users, :colour, :string, default: nil
  end

  def down
    change_column :users, :colour, :string, default: 'green'
  end
end

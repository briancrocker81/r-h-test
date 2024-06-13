class AddUserColourAndRoleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :colour, :string, default: 'green', limit: 15
    add_column :users, :role, :string, limit: 50
  end
end

class AddUserDetailsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :first_name, :string
    add_column :users, :surname, :string
    add_column :users, :username, :string, unique: true
    add_column :users, :mobile, :string
    add_column :users, :admin, :boolean
  end
end

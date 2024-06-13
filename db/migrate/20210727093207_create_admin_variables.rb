class CreateAdminVariables < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_variables do |t|
      t.boolean :rightmove, default: false
      t.boolean :zoopla, default: false
      t.boolean :onthemarket, default: false
      t.timestamps
    end
    add_index :admin_variables, :rightmove
    add_index :admin_variables, :zoopla
    add_index :admin_variables, :onthemarket
  end
end

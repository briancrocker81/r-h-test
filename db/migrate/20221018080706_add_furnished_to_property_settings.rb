class AddFurnishedToPropertySettings < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :furnished, :integer, default: 2
  end
end

class AddLetTypeToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :rental_type, :integer
  end
end

class AddTypeToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :property_status_type, :integer
  end
end

class AddAvailableDateToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :date_available, :date
  end
end

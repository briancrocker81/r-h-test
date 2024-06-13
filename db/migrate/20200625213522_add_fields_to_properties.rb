class AddFieldsToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :on_market, :boolean
    add_column :properties, :next_available_date, :date
  end
end

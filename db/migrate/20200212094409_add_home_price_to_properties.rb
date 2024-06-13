class AddHomePriceToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :home_rental_price, :decimal
  end
end

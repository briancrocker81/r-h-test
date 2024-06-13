class AddColumsTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :weekly_price, :decimal
    add_column :tenancies, :monthly_price, :decimal
  end
end

class ItemYearPaymentItems < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancy_payment_items, :item_year, :string
  end
end

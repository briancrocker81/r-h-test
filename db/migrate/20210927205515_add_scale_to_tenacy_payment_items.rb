class AddScaleToTenacyPaymentItems < ActiveRecord::Migration[5.2]
  def change
    change_column :tenancy_payment_items, :amount_due, :decimal, precision: 10, scale: 2
    change_column :tenancy_payment_items, :amount_paid, :decimal, precision: 10, scale: 2
  end
end

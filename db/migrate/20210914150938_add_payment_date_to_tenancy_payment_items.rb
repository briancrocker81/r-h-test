class AddPaymentDateToTenancyPaymentItems < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancy_payment_items, :date_paid, :date
  end
end

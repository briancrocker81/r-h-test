class AddInitialPaymentToTenancy < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :initial_payment, :decimal, precision: 8, scale: 2
    add_column :tenancies, :initial_payment_date, :date
    add_column :tenancies, :initial_payment_paid, :boolean
  end
end

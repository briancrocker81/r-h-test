class AddNewPaymentOptionsToTenancy < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :total_tenancy_value, :string
    add_column :tenancies, :number_of_payments, :integer
    add_column :tenancies, :payment_amount, :decimal
  end
end

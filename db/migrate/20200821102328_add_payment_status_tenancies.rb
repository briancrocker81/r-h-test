class AddPaymentStatusTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :payment_status, :string, default: 'unpaid'
    add_column :tenancies, :booking_status, :string, default: 'available'
  end
end

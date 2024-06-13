class AddBookingFormDetailsToTenancy < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :emergency_contact_name, :string
    add_column :tenancies, :emergency_contact_number, :string
    add_column :tenancies, :advanced_rent_payment_amount, :decimal
    add_column :tenancies, :advanced_rent_payment_date, :date
    add_column :tenancies, :payment_card_pan, :string
    add_column :tenancies, :payment_card_expiry, :date
    add_column :tenancies, :payment_card_cvc, :integer, limit: 3
  end
end

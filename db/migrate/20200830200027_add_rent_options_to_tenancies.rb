class AddRentOptionsToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :rent_payment_option, :string
  end
end

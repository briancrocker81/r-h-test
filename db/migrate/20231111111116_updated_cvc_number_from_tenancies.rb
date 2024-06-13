class UpdatedCvcNumberFromTenancies < ActiveRecord::Migration[5.2]
  def change
    change_column :tenancies, :payment_card_cvc, :string
  end
end

class AddPaymentReferenceToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :bank_payment_reference, :string
  end
end

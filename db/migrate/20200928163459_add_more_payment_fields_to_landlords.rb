class AddMorePaymentFieldsToLandlords < ActiveRecord::Migration[5.2]
  def change
    add_column :landlords, :bic, :string
    add_column :landlords, :iban, :string
    add_column :landlords, :pay_direct, :boolean
  end
end

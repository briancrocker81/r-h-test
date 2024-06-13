class AddBankingDetailsToLandlord < ActiveRecord::Migration[5.2]
  def change
    add_column :landlords, :account_name, :string
    add_column :landlords, :bank_name, :string
    add_column :landlords, :bank_address, :text
    add_column :landlords, :bank_sort_code, :string
    add_column :landlords, :bank_account_number, :string
  end
end

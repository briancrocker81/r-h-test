class AddDepositPaidToTenancy < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :deposit_paid, :boolean
  end
end

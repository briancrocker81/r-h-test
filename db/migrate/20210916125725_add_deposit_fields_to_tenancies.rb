class AddDepositFieldsToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :deposit_protected, :boolean
    add_column :tenancies, :prescribed_info_sent, :boolean
  end
end

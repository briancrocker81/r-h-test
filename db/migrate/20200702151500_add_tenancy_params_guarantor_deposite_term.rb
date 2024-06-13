class AddTenancyParamsGuarantorDepositeTerm < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :is_guarantor_available, :boolean
    add_column :tenancies, :deposit_term, :string
  end
end

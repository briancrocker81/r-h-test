class AddAgreementFieldsToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :special_conditions, :text
    add_column :tenancies, :deposit_date, :date
    add_column :tenancies, :deposit_guarantor_amount, :decimal
  end
end

class AddFieldsToTenancy < ActiveRecord::Migration[5.2]
  def up
    add_column :tenancies, :rent_due_date, :date
    add_column :tenancies, :rent_installment_term, :integer, default: 0
  end

  def down
    remove_column :tenancies, :rent_due_date, :datetime
    remove_column :tenancies, :rent_installment_term, :integer, default: 0
  end
end

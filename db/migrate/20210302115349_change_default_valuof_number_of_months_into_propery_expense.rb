class ChangeDefaultValuofNumberOfMonthsIntoProperyExpense < ActiveRecord::Migration[5.2]
  def up
    change_column :property_expenses, :number_of_months, :integer, default: nil
    add_column :property_expenses, :status, :integer, default: 0
    add_index :property_expenses, :status
  end

  def down
    change_column :property_expenses, :number_of_months, :integer, default: 0
    remove_index :property_expenses, :status
    remove_column :property_expenses, :status, :integer
  end
end

class AddStatementTypeIntoLandlordStatement < ActiveRecord::Migration[5.2]
  def up
    add_column :landlord_statement_reports, :statement_type, :integer, default: 0
    add_index :landlord_statement_reports, :statement_type
  end

  def down
    remove_index :landlord_statement_reports, :statement_type
    remove_column :landlord_statement_reports, :statement_type, :integer, default: 0
  end
end

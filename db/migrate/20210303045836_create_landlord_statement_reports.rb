class CreateLandlordStatementReports < ActiveRecord::Migration[5.2]
  def change
    create_table :landlord_statement_reports do |t|
      t.integer :landlord_id
      t.integer :property_id
      t.boolean :mail_sent, default: false
      t.string  :statement_report
      t.timestamps
    end
    add_index :landlord_statement_reports, :landlord_id
    add_index :landlord_statement_reports, :property_id
    add_index :landlord_statement_reports, :mail_sent
  end
end

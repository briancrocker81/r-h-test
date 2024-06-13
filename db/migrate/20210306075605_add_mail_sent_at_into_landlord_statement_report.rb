class AddMailSentAtIntoLandlordStatementReport < ActiveRecord::Migration[5.2]
  def change
    add_column :landlord_statement_reports, :mail_sent_at, :datetime
    add_column :landlord_statement_reports, :year, :string
    add_index  :landlord_statement_reports, :mail_sent_at
    add_index  :landlord_statement_reports, :year
  end
end

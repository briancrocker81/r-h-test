class CreatePropertyReports < ActiveRecord::Migration[5.2]
  def change
    create_table :property_reports do |t|
      t.integer :report_type, default: 0
      t.integer :run_by
      t.string :year
      t.string :report
      t.boolean :mail_sent, default: false
      t.datetime :mail_sent_at
      t.datetime :start_run_at
      t.datetime :end_run_at
      t.timestamps
    end
    add_index :property_reports, :run_by
    add_index :property_reports, :mail_sent
    add_index :property_reports, :report_type
    add_index :property_reports, :year
    add_index :property_reports, :start_run_at
    add_index :property_reports, :end_run_at
  end
end

class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.integer :landlord_id
      t.integer :property_id
      t.integer :term_type
      t.integer :report_type
      t.integer :month
      t.integer :report_type
      t.string  :report
      t.string  :year
      t.datetime :mail_sent_at
      t.boolean :mail_sent, default: false
      t.timestamps
    end
    add_index :reports, :landlord_id
    add_index :reports, :property_id
    add_index :reports, :term_type
    add_index :reports, :report_type
    add_index :reports, :year
    add_index :reports, :month
    add_index :reports, :mail_sent
  end
end

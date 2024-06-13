class CreateCustomPropertyReports < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_property_reports do |t|
      t.date :start_date
      t.date :end_date
      t.integer :run_by_id
      t.string :year
      t.integer :month
      t.timestamps
    end
    add_index :custom_property_reports, :run_by_id
  end
end

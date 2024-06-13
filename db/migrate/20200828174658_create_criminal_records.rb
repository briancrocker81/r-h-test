class CreateCriminalRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :criminal_records do |t|
      t.string :conviction_status
      t.string :offence
      t.date :date
      t.string :judgement
      t.references :tenancy, foreign_key: true

      t.timestamps
    end
  end
end

class CreateTenancyHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :tenancy_histories do |t|
      t.references :tenancy, foreign_key: true
      t.integer :original_id

      t.timestamps
    end
  end
end

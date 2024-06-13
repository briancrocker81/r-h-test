class CreateTenancyIdentifications < ActiveRecord::Migration[5.2]
  def change
    create_table :tenancy_identifications do |t|
      t.references :tenancy, foreign_key: true
      t.integer :staff_id
      t.string :id_proof_name
      t.string :id_proof_number
      t.string :id_proof_doc
      t.boolean :verified, default: false
      t.timestamp :verified_at

      t.timestamps
    end
  end
end

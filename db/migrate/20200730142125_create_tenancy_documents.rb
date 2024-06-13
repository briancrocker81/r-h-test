class CreateTenancyDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :tenancy_documents do |t|
      t.string :document_name
      t.string :document_file
      t.references :tenancy, foreign_key: true
      t.boolean :verified, default: false
      t.timestamp :verified_at
      t.integer :staff_id
      t.boolean :active, default: true
      
      t.timestamps
    end
  end
end

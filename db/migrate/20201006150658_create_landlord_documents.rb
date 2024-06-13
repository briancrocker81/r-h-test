class CreateLandlordDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :landlord_documents do |t|
      t.string :document_name
      t.string :document_file
      t.boolean :active, default: true
      t.references :landlord, foreign_key: true
      t.timestamps
    end
  end
end

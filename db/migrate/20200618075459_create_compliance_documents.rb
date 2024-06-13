class CreateComplianceDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_column :properties, :compliance_doc, :string
    create_table :compliance_documents do |t|
      t.string :document_name
      t.string :document_file
      t.date :document_expiry
      t.boolean :active, default: true
      t.references :property, foreign_key: true
      t.timestamps
    end
  end
end

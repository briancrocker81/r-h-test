class CreateGenericDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :generic_documents do |t|
      t.string :document_name
      t.string :document_file
      t.date :document_expiry
      t.boolean :active
      t.bigint :admin_id
      t.timestamps
    end
    add_index :generic_documents, :admin_id
    add_index :generic_documents, :active
  end
end

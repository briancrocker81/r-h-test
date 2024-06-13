class AddGenericDocumentIdIntoComplianceDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :compliance_documents, :generic_document_id, :integer
    add_index  :compliance_documents, :generic_document_id
  end
end

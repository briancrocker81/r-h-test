class RemoveCompliancePropertyAddToRoomAndTenancy < ActiveRecord::Migration[5.2]
  def change
    remove_reference :compliance_documents, :property, index: true
    add_reference :compliance_documents, :tenancy, index: true
    add_reference :compliance_documents, :room, index: true
  end
end

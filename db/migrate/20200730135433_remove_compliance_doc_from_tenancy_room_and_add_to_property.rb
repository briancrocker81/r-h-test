class RemoveComplianceDocFromTenancyRoomAndAddToProperty < ActiveRecord::Migration[5.2]
  def change
    add_reference :compliance_documents, :property, index: true
    remove_reference :compliance_documents, :tenancy, index: true
    remove_reference :compliance_documents, :room, index: true
  end
end

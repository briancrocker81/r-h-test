class RemoveIdNumberFromTenancyIdentifications < ActiveRecord::Migration[5.2]
  def change
    remove_column :tenancy_identifications, :id_proof_number
  end
end

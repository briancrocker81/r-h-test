class RemoveColumnsFromTenancy < ActiveRecord::Migration[5.2]
  def change
    remove_column :tenancies, :tenancy_rate
    remove_column :tenancies, :status
    remove_column :tenancies, :id_proof_no
    remove_column :tenancies, :id_proof_image

    rename_column :tenancies, :zip, :post_code
  end
end

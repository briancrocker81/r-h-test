class AgreementDetailsTenancy < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :id_proof_no, :string
    add_column :tenancies, :id_proof_image, :string
    add_column :tenancies, :address, :text
    add_column :tenancies, :state, :string
    add_column :tenancies, :city, :string
    add_column :tenancies, :zip, :string
    add_column :tenancies, :signature, :string
    add_column :tenancies, :signed_date_time, :datetime
    add_column :tenancies, :final_submission, :boolean, default: false
  end
end

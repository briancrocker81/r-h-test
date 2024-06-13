class AddTenancyAgreementSignatureToTenancy < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :tenancy_agreement_signature, :string
  end
end

class AddCompleteGuarantorAgreementIntoGuarantor < ActiveRecord::Migration[5.2]
  def change
    change_column :guarantors, :own_property, :boolean, default: false
    add_column :guarantors, :complete_guarantor_agreement, :boolean, default: false
  end
end

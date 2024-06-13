class AddConfirmSignedTenancyIntoGuarantor < ActiveRecord::Migration[5.2]
  def change
    add_column :guarantors, :confirm_signed_tenancy, :boolean ,default: false
  end
end

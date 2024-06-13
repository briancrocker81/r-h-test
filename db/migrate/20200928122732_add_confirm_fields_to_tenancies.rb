class AddConfirmFieldsToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :confirm_tenancy, :boolean
  end
end

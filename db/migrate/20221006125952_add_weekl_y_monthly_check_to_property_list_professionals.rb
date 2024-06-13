class AddWeeklYMonthlyCheckToPropertyListProfessionals < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_professionals, :list_weekly, :boolean
    add_column :property_list_professionals, :list_monthly, :boolean, null: false, default: 1
  end
end

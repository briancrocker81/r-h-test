class AddWeeklYMonthlyCheckToPropertyListFamily < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_families, :list_weekly, :boolean
    add_column :property_list_families, :list_monthly, :boolean, null: false, default: 1
  end
end

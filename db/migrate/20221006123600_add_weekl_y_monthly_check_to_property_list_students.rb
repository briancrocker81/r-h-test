class AddWeeklYMonthlyCheckToPropertyListStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_students, :list_weekly, :boolean, null: false, :default => 1
    add_column :property_list_students, :list_monthly, :boolean
  end
end

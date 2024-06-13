class AddLettingFieldsToPropertyListStudent < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_students, :let_available_date, :date
    add_column :property_list_students, :deposit, :decimal, precision: 6, scale: 2
    add_column :property_list_students, :minimum_term, :integer
  end
end

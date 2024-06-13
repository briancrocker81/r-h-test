class AddLettingFieldsToPropertyListGraduate < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_graduates, :let_available_date, :date
    add_column :property_list_graduates, :deposit, :decimal, precision: 6, scale: 2
    add_column :property_list_graduates, :minimum_term, :integer
  end
end

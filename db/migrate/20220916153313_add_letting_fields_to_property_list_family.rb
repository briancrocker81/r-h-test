class AddLettingFieldsToPropertyListFamily < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_families, :let_available_date, :date
    add_column :property_list_families, :deposit, :decimal, precision: 6, scale: 2
    add_column :property_list_families, :minimum_term, :integer
  end
end

class AddLettingFieldsToPropertyListProfessional < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_professionals, :let_available_date, :date
    add_column :property_list_professionals, :deposit, :decimal, precision: 6, scale: 2
    add_column :property_list_professionals, :minimum_term, :integer
  end
end

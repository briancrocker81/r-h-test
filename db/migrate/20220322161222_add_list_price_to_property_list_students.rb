class AddListPriceToPropertyListStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_students, :list_price, :decimal, precision: 8, scale: 2
  end
end

class AddListPriceToPropertyListGraduates < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_graduates, :list_price, :decimal, precision: 8, scale: 2
  end
end

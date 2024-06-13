class CreatePropertyExpenses < ActiveRecord::Migration[5.2]
  def change
    create_table :property_expenses do |t|
      t.integer :property_id
      t.integer :number_of_months, default: 0
      t.integer :category
      t.string :year
      t.string :name
      t.string :file
      t.decimal :amount, default: 0.0
      t.boolean :recurring, default: false
      t.date :expense_date
      t.timestamps
    end
    add_index :property_expenses, :property_id
    add_index :property_expenses, :expense_date
    add_index :property_expenses, :year

  end
end

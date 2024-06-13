class CreateTenancyPaymentItems < ActiveRecord::Migration[5.2]
  def change
    create_table :tenancy_payment_items do |t|
      t.references :tenancy, foreign_key: true
      t.string :item
      t.string :item_type
      t.date :due_date
      t.decimal :amount_due
      t.decimal :amount_paid
      t.string :arrears
      t.string :payment_method

      t.timestamps
    end
  end
end

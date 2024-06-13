class CreateAdditionalTenants < ActiveRecord::Migration[5.2]
  def change
    create_table :additional_tenants do |t|
      t.string :first_name
      t.string :surname
      t.string :phone_number
      t.text :address
      t.string :email
      t.string :signature
      t.date :signed_date
      t.boolean :accept_agreement
      t.references :tenancy, foreign_key: true

      t.timestamps
    end
  end
end

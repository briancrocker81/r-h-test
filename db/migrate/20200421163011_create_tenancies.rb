class CreateTenancies < ActiveRecord::Migration[5.2]
  def change
    create_table :tenancies do |t|
      t.references :property, foreign_key: true
      t.boolean :tenancy_rate
      t.integer :rate
      t.boolean :tenant_type
      t.date :tenancy_start
      t.date :tenancy_end
      t.string :first_name
      t.string :surname
      t.date :dob
      t.string :mobile
      t.string :email
      t.string :nationality
      t.boolean :criminal_record
      t.boolean :accept_agreement
      t.string :year
      t.boolean :status

      t.timestamps
    end
  end
end

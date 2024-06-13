class CreateGuarantors < ActiveRecord::Migration[5.2]
  def change
    create_table :guarantors do |t|
      t.string :guarantor_name
      t.text :guarantor_address
      t.string :guarantor_post_code
      t.string :guarantor_email
      t.string :guarantor_mobile
      t.string :guarantor_relationship
      t.references :tenancy, foreign_key: true
      
      t.timestamps
    end
  end
end

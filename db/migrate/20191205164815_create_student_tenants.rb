class CreateStudentTenants < ActiveRecord::Migration[5.2]
  def change
    create_table :student_tenants do |t|
      t.string :studying_at
      t.string :student_id_number
      t.string :course
      t.string :guarantor_name
      t.text :guarantor_address
      t.string :guarantor_post_code
      t.string :guarantor_email
      t.string :guarantor_mobile
      t.string :guarantor_relationship

      t.references :tenant, foreign_key: true

      t.timestamps
    end
  end
end

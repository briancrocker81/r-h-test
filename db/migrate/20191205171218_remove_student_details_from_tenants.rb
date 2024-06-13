class RemoveStudentDetailsFromTenants < ActiveRecord::Migration[5.2]
  def change
    remove_column :tenants, :studying_at
    remove_column :tenants, :student_id_number
    remove_column :tenants, :course
    remove_column :tenants, :guarantor_name
    remove_column :tenants, :guarantor_address
    remove_column :tenants, :guarantor_post_code
    remove_column :tenants, :guarantor_email
    remove_column :tenants, :guarantor_mobile
    remove_column :tenants, :guarantor_relationship
  end
end

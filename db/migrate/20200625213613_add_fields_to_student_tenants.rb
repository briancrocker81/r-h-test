class AddFieldsToStudentTenants < ActiveRecord::Migration[5.2]
  def change
    add_reference :student_tenants, :tenancies, foreign_key: true
  end
end

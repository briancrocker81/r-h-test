class CreateStudentCourseDetails < ActiveRecord::Migration[5.2]
  drop_table :student_tenants
  def change
    create_table :student_course_details do |t|
      t.string :studying_at
      t.string :student_id_number
      t.string :course
      t.references :tenancy, foreign_key: true

      t.timestamps
    end
  end
end

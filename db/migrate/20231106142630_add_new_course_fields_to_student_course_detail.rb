class AddNewCourseFieldsToStudentCourseDetail < ActiveRecord::Migration[5.2]
  def change
    add_column :student_course_details, :course_start, :date
    add_column :student_course_details, :course_end, :date
  end
end

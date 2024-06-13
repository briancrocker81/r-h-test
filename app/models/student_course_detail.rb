class StudentCourseDetail < ApplicationRecord

  ##Accessor
  attr_accessor :validate_student

  ## Association
  belongs_to :tenancy

  ## validation
  # validate :validate_student_details

  ## Custom validation for student tenant
  def validate_student_details
    errors.add(:student_id_number, "Please add student id number") if student_id_number.blank? && validate_student
  end
end

class ProfessionalDetail < ApplicationRecord

  ##Accessor
  attr_accessor :validate_professional

  ##validation
  # validate :professional_working_at

  ## Association
  belongs_to :tenancy

  def salary_type_nice_name(option)
    if option == "0" || option == 0
      "Annual"
    elsif option == "1" || option == 1
      "Monthly"
    elsif option == "2" || option == 2
      "Weekly"
    else
      'Not Defined'
    end
  end

  def employment_type_nice_name(option)
    if option == "0" || option == 0
      "Full Time"
    elsif option == "1" || option == 1
      "Part Time"
    elsif option == "2" || option == 2
      "Temporary"
    else
      'Not Defined'
    end
  end

  ## Custom validation for professional
  def professional_working_at
    errors.add(:working_at, "it is required") if working_at.blank? && validate_professional
  end
end

class Tenant < ApplicationRecord
  belongs_to :room
  belongs_to :property, optional: true
  has_many :student_tenants
  accepts_nested_attributes_for :student_tenants

  def tenant_full_name
    "#{first_name} #{surname}"
  end
end

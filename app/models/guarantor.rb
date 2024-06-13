class Guarantor < ApplicationRecord
  mount_base64_uploader :guarantor_signature, AttachmentUploader, file_name: -> (g) { "guarantor-sig-"+g.id.to_s }
  mount_uploader :photo_id, AttachmentUploader
  mount_uploader :utility_bill, AttachmentUploader

  amoeba do
    enable
    nullify :uri_string
    customize(lambda do |op, np|
      np.guarantor_signature = op.guarantor_signature
      np.photo_id = op.photo_id
      np.utility_bill = op.utility_bill
    end)
  end

  ## enum
  enum employment_status: [:employed, :retired]

  ## Association
  belongs_to :tenancy
  after_save :update_uri_string

  ##Accessor
  attr_accessor :validate_guarantor_dashboard, :validate_guarantor_confirmed

  ## Validates
  # validates :guarantor_name, presence: true
  # validates :guarantor_email, presence: true
  # validates :guarantor_mobile, presence: true
  validate :guarantor_dashboard
  validate :guarantor_confirmed

  def update_uri_string
    if self.uri_string.nil?
      uri_string = SecureRandom.urlsafe_base64(nil, false)
      uri_string = uri_string unless Guarantor.exists?(uri_string: uri_string)
      self.update_column(:uri_string, uri_string)
    end
  end

  ## Custom validation

  def guarantor_dashboard
    if validate_guarantor_dashboard
      errors.add(:guarantor_address, "Please add the address") if guarantor_address.blank?
      errors.add(:contact_number, "Please add the contact number") if contact_number.blank?
      errors.add(:net_salary, 'Please add the monthly net salary') if net_salary.blank?
      errors.add(:date_of_birth, "Please add the date of birth") if date_of_birth.blank?
      errors.add(:confirm_guarantor, "Please agree to confirm") if confirm_guarantor.blank?
      # errors.add(:own_property, 'Please check the own property') if own_property
    end
  end

  def guarantor_confirmed
    if validate_guarantor_confirmed && confirm_signed_tenancy.blank? && !confirm_signed_tenancy
      errors.add(:confirm_signed_tenancy, "Please confirmed the tenancy signed booking form")
    end
  end
end

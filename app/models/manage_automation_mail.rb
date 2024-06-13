class ManageAutomationMail < ApplicationRecord

  ## serialize
  serialize :mail_methods, Array

  ## Automation Mails
  AUTOMATION_MAILS = ['Event Mailer', 'Guarantor Mailer', 'Landlord Mailer', 'Property Mailer', 'Tenancy Mailer']

  ## Validation
  validates :mail_type, presence: true, uniqueness: true
end

class Report < ApplicationRecord

  ## Uploader
  mount_uploader :report, AttachmentUploader

  ## enum
  enum term_type: %w(monthly yearly)
  enum report_type: %w(landlord_statement full_listing_monthly annual_income annual_rent sales_analysis availability payment)

  ## association
  belongs_to :landlord, optional: true
  belongs_to :property, optional: true

  ## validation
  validates :term_type, :report_type, :year, :month, :report, presence: true
end

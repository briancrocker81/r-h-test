class LandlordStatementReport < ApplicationRecord
  ## Uploader
  mount_uploader :statement_report, AttachmentUploader

  ## Association
  belongs_to :property
  belongs_to :landlord

  ## validateion
  validates :statement_type, presence: true

  ## enum
  enum statement_type: %w(monthly yearly)


end

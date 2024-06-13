class PropertyReport < ApplicationRecord
  ## Uploader
  mount_uploader :report, AttachmentUploader

  ## validation
  validates :year, :report_type, presence: true

  ## Association
  belongs_to :user, foreign_key: :run_by, optional: true

  ## enum
  enum report_type: %w(monthly yearly)
end

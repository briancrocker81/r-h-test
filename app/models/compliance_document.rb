class ComplianceDocument < ApplicationRecord
  mount_uploader :document_file, AttachmentUploader
  belongs_to :property
  belongs_to :generic_document, optional: true
end

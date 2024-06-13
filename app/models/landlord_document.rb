class LandlordDocument < ApplicationRecord
  mount_uploader :document_file, AttachmentUploader
  DOCUMENTS = ["partner_agreement", "property_form"]
  belongs_to :landlord
end

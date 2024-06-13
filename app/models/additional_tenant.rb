class AdditionalTenant < ApplicationRecord
  belongs_to :tenancy

  mount_base64_uploader :signature, AttachmentUploader, file_name: -> (t) { "additional-tenant-sig-"+t.id.to_s }
end

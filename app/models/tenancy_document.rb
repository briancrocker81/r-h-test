class TenancyDocument < ApplicationRecord
  PDF_FILE_NAMES = {
    'TenancyBookingPdf' => 'booking_form.pdf',
    'TenancyDocumentPdf' => 'compliance_document.pdf',
    'TenancyAgreementPdf' => 'tenancy_agreement.pdf'
  }.freeze

  PDF_DOCUMENT_NAMES = {
    'TenancyBookingPdf' => 'booking_form',
    'TenancyDocumentPdf' => 'tenancy_compliance',
    'TenancyAgreementPdf' => 'signed_tenancy_agreement'
  }.freeze

  mount_uploader :document_file, AttachmentUploader

  belongs_to :tenancy
  belongs_to :user, class_name: 'User', foreign_key: 'staff_id', optional: true

  amoeba do
    enable
    customize(lambda do |op, np|
      np.document_file = op.document_file
    end)
  end
end

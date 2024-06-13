class GenericDocument < ApplicationRecord
  REQUIRED_DOCUMENT_TYPES = {
    'epc': 'Energy Performance EPC',
    'electrical-wiring': 'Electrical Wiring',
    'gas-safety': 'Gas Safety',
  }
  DOCUMENT_TYPES = {
    'epc': 'Energy Performance EPC',
    'electrical-wiring': 'Electrical Wiring',
    'emergency-lighting': 'Emergency Lighting',
    'fire-alarm-test': 'Fire Alarm Test',
    'pat-testing': 'PAT Test',
    'fire-risk-assessment': 'Fire Risk Assessment',
    'gas-safety': 'Gas Safety',
    'how-to-rent-guid': 'How To Rent Guid',
    'right-to-rent-id': 'Right To Rent',
    'generic-document': 'Generic Document',
    'fair-usage-policy': 'Fair Usage Policy'
  }
  GENERIC_DOCUMENT_TYPES = DOCUMENT_TYPES.slice(:'how-to-rent-guid', :'right-to-rent-id', :'generic-document', :'fair-usage-policy')

  ## Uploader
  mount_uploader :document_file, AttachmentUploader

  ## Association
  belongs_to :admin, class_name: 'User', foreign_key: :admin_id
  has_many :compliance_documents

  ## callbacks
  before_destroy :remove_from_property_documents
  after_create_commit :add_into_existing_properties
  after_update :update_into_existing_properties, if: -> { saved_change_to_document_file? || saved_change_to_document_expiry? }

  ## validation
  validates :document_name, :document_expiry, :document_file, presence: true
  validates :document_name, uniqueness: true

  ## private

  def remove_from_property_documents
    compliance_documents = ComplianceDocument.where(generic_document_id: id)
    compliance_documents.delete_all
  end

  def add_into_existing_properties
    Property.all.each do |property|
      compliance_document = property.compliance_documents.find_or_initialize_by(document_name: document_name)
      compliance_document.document_expiry = document_expiry
      compliance_document.document_file = document_file
      compliance_document.generic_document_id = id
      compliance_document.save
    end
  end

  def update_into_existing_properties
    compliance_documents = ComplianceDocument.where(generic_document_id: id)
    compliance_documents.each do |compliance_document|
      compliance_document.document_name = document_name
      compliance_document.document_expiry = document_expiry
      compliance_document.document_file = document_file
      compliance_document.save
    end
  end
end

class TenancyIdentification < ApplicationRecord
  mount_uploader :id_proof_doc, AttachmentUploader
  
  belongs_to :users, class_name: 'User', foreign_key: 'staff_id'
  belongs_to :tenancy

  validates_presence_of :id_proof_name
  after_save :check_verified?

  amoeba do
    enable
    customize(lambda do |op, np|
      np.id_proof_doc = op.id_proof_doc
    end)
  end

  protected

  def check_verified?
    if (self.verified && self.id_proof_doc != "")
      self.update_column(:verified_at, Time.now)
    elsif !self.verified
      self.update_columns({verified_at: nil, staff_id: nil})
    end
  end
end

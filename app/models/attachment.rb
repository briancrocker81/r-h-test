class Attachment < ApplicationRecord
  mount_uploader :attachment, AttachmentUploader

  # Associations

  belongs_to :attached_item, polymorphic: true

  # Validations

  # validates_presence_of :attachment
  # validates_integrity_of :attachment

  # Callbacks

  #before_save :update_attachment_attributes

  # Delegate

  delegate :url, :size, :path, to: :attachment

  # private

  # def update_attachment_attributes
  #   if attachment.present? && attachment_changed?
  #     self.original_filename = attachment.file.original_filename
  #     self.content_type = attachment.file.content_type
  #   end
  # end

  def self.to_jsn
    all.map do |image|
      {
        id: image.id,
        url: image.attachment_url
      }
    end
  end
end

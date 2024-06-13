class LandlordStaffMessage < ApplicationRecord
  belongs_to :landlord_staff_conversation
  belongs_to :sender, polymorphic: true
  belongs_to :receiver, polymorphic: true
  # belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  # belongs_to :sender, class_name: "Tenancy", foreign_key: "sender_id"
  # belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"
  # belongs_to :receiver, class_name: "Tenancy", foreign_key: "receiver_id"

  validates_presence_of :body, :subject, :landlord_staff_conversation_id, :sender, :receiver

  def message_time
    created_at.strftime("%d/%m/%y at %l:%M %p")
  end
end

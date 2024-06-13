class LandlordStaffConversation < ApplicationRecord
  belongs_to :landlord
  has_many :landlord_staff_messages, dependent: :destroy
end

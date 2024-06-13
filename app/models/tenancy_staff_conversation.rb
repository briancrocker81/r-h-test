class TenancyStaffConversation < ApplicationRecord
  belongs_to :tenancy
  has_many :tenancy_staff_messages, dependent: :destroy
end

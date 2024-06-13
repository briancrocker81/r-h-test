class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"

  validates_presence_of :body, :conversation_id, :sender_id

  def message_time
    created_at.strftime("%d/%m/%y at %l:%M %p")
  end  
end

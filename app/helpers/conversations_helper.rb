module ConversationsHelper
  def get_conversation_thread(conversation_id)
    messages = Message.where(conversation_id: conversation_id).order('created_at')
  end
end

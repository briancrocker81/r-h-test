class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    conversation = Conversation.find params[:conversation_id]
    reply_to_message = Message.find params[:message_id]
    if conversation.present?
      message = conversation.messages.build({sender_id: current_user.id, receiver_id: reply_to_message.sender_id, body: message_params[:body]})
      if message.save
        flash[:notice] = "Message sent successfully!"
        redirect_to property_path(conversation.property_id)
      else
        flash[:alert] = "Server error please try again later!"
        redirect_to property_path(conversation.property_id)
      end
    else
      flash[:alert] = "Conversation not found!"
      redirect_to property_path(conversation.property_id)
    end
  end
  
  def update
    message = Message.find params[:id]  
    if message.present?
      if message.update(body: message_params[:body])
        flash[:notice] = "Message update successfully!"
        redirect_to property_path(message.conversation.property_id)
      else
        flash[:alert] = "Server error please try again later!"
        redirect_to property_path(message.conversation.property_id)
      end
    else
      flash[:alert] = "Message not found!"
      redirect_to property_path(message.conversation.property_id)
    end
  end

  def destroy
    message = Message.find params[:id]
    if message.destroy
      flash[:notice] = "Message delete successfully!"
      redirect_to property_path(message.conversation.property_id)
    else
      flash[:alert] = "Server error please try again later!"
      redirect_to property_path(message.conversation.property_id)
    end
  end

  private
    def message_params
      params.permit(:body)
    end
end

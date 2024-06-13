class LandlordStaffMessagesController < ApplicationController

  def reply_form
    @message = LandlordStaffMessage.find params[:message_id]
  end

  def create
    conversation = LandlordStaffConversation.find params[:landlord_staff_conversation_id]
    reply_to_message = LandlordStaffMessage.find params[:message_id]
    if conversation.present?
      if current_user.present?
        from = 'staff'
        message = conversation.landlord_staff_messages.new(sender: current_user, receiver: reply_to_message.sender, body: message_params[:body], subject: message_params[:subject], from: from)
        # sender_id = current_user.id
        # receiver_id = reply_to_message.sender_id
      else
        from = 'landlord'
        message = conversation.landlord_staff_messages.new(sender: conversation.landlord, receiver: reply_to_message.sender, body: message_params[:body], subject: message_params[:subject], from: from)
        # sender_id = conversation.tenacy_id
        # receiver_id = reply_to_message.sender_id
      end
      # message = conversation.landlord_staff_messages.build({sender_id: current_user.id, receiver_id: reply_to_message.sender_id, body: message_params[:body], subject: message_params[:subject], from: from})
      if message && message.save
        flash[:notice] = "Message sent successfully!"
        redirect_to landlord_path(conversation.landlord_id)
      else
        flash[:alert] = "Server error please try again later!"
        redirect_to landlord_path(conversation.landlord_id)
      end
    else
      flash[:alert] = "Conversation not found!"
      redirect_to landlord_path(conversation.landlord_id)
    end
  end

  def update
    message = LandlordStaffMessage.find params[:id]
    if message.present?
      if message.update({body: message_params[:body], subject: message_params[:subject]})
        flash[:notice] = "Message update successfully!"
        redirect_to landlord_path(message.landlord_staff_conversation.landlord_id)
      else
        flash[:alert] = "Server error please try again later!"
        redirect_to landlord_path(message.landlord_staff_conversation.landlord_id)
      end
    else
      flash[:alert] = "Message not found!"
      redirect_to landlord_path(message.landlord_staff_conversation.landlord_id)
    end
  end

  def destroy
    message = LandlordStaffMessage.find params[:id]
    if message.destroy
      flash[:notice] = "Message delete successfully!"
      redirect_to landlord_path(message.landlord_staff_conversation.landlord_id)
    else
      flash[:alert] = "Server error please try again later!"
      redirect_to landlord_path(message.landlord_staff_conversation.landlord_id)
    end
  end

  private
    def message_params
      params.permit(:body, :subject)
    end
end

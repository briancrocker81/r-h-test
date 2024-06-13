class TenancyStaffMessagesController < ApplicationController

  def reply_form
    @message = TenancyStaffMessage.find params[:message_id]
  end

  def create
    conversation = TenancyStaffConversation.find params[:tenancy_staff_conversation_id]
    reply_to_message = TenancyStaffMessage.find params[:message_id]
    if conversation.present?
      if current_user.present?
        from = 'staff'
        message = conversation.tenancy_staff_messages.new(sender: current_user, receiver: reply_to_message.receiver, body: message_params[:body], subject: message_params[:subject], from: from)
        # sender_id = current_user.id
        # receiver_id = reply_to_message.sender_id
      else
        from = 'tenancy'
        message = conversation.tenancy_staff_messages.new(sender: conversation.tenancy, receiver: reply_to_message.sender, body: message_params[:body], subject: message_params[:subject], from: from)
        # sender_id = conversation.tenacy_id
        # receiver_id = reply_to_message.sender_id
      end
      # message = conversation.tenancy_staff_messages.build({sender_id: current_user.id, receiver_id: reply_to_message.sender_id, body: message_params[:body], subject: message_params[:subject], from: from})
      if message && message.save
        flash[:notice] = "Message sent successfully!"
        redirect_to tenancy_path(conversation.tenancy_id)
      else
        flash[:alert] = "Server error please try again later!"
        redirect_to tenancy_path(conversation.tenancy_id)
      end
    else
      flash[:alert] = "Conversation not found!"
      redirect_to tenancy_path(conversation.tenancy_id)
    end
  end

  def update
    message = TenancyStaffMessage.find params[:id]
    if message.present?
      if message.update({body: message_params[:body], subject: message_params[:subject]})
        flash[:notice] = "Message update successfully!"
        redirect_to tenancy_path(message.tenancy_staff_conversation.tenancy_id)
      else
        flash[:alert] = "Server error please try again later!"
        redirect_to tenancy_path(message.tenancy_staff_conversation.tenancy_id)
      end
    else
      flash[:alert] = "Message not found!"
      redirect_to tenancy_path(message.tenancy_staff_conversation.tenancy_id)
    end
  end

  def destroy
    message = TenancyStaffMessage.find params[:id]
    if message.destroy
      flash[:notice] = "Message delete successfully!"
      redirect_to tenancy_path(message.tenancy_staff_conversation.tenancy_id)
    else
      flash[:alert] = "Server error please try again later!"
      redirect_to tenancy_path(message.tenancy_staff_conversation.tenancy_id)
    end
  end

  private
    def message_params
      params.permit(:body, :subject)
    end
end

class LandlordStaffConversationsController < ApplicationController

  def new
    @landlord = Landlord.find params[:landlord_id]
  end

  def create
    landlord = Landlord.find conversation_params[:landlord_id]
    if landlord.present?
      conversation = LandlordStaffConversation.create!({landlord_id: landlord.id})
      if current_user.present?
        from = 'staff'
        message = conversation.landlord_staff_messages.new(sender: current_user, receiver: landlord, body: conversation_params[:body], subject: conversation_params[:subject], from: from)
        # sender_id = current_user.id
        # receiver_id = landlord.id
      else
        from = 'landlord'
        message = conversation.landlord_staff_messages.new(sender: landlord, receiver: landlord, body: conversation_params[:body], subject: conversation_params[:subject], from: from)
        # sender_id = landlord.id
        # receiver_id = landlord.id
      end
      # message = conversation.landlord_staff_messages.build({sender_id: sender_id, receiver_id: receiver_id, body: conversation_params[:body], subject: conversation_params[:subject], from: from})
      if message && message.save
        flash[:notice] = "Conversation saved!"
        redirect_to landlord_path(landlord)
      else
        flash[:alert] = "Server error please try again later!"
        redirect_to landlord_path(landlord)
      end
    else
      flash[:alert] = "No landlord found!"
      redirect_to landlord_path(landlord)
    end
  end

  private
    def conversation_params
      params.permit(:landlord_id, :subject, :body)
    end
end

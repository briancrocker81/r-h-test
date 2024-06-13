class TenancyStaffConversationsController < ApplicationController

  def new
    @tenancy = Tenancy.find params[:tenancy_id]
  end

  def create
    tenancy = Tenancy.find conversation_params[:tenancy_id]
    if tenancy.present?
      conversation = TenancyStaffConversation.create!({tenancy_id: tenancy.id})
      if current_user.present?
        from = 'staff'
        message = conversation.tenancy_staff_messages.new(sender: current_user, receiver: tenancy, body: conversation_params[:body], subject: conversation_params[:subject], from: from)
        # sender_id = current_user.id
        # receiver_id = tenancy.id
      else
        from = 'tenancy'
        message = conversation.tenancy_staff_messages.new(sender: tenancy, receiver: tenancy, body: conversation_params[:body], subject: conversation_params[:subject], from: from)
        # sender_id = tenancy.id
        # receiver_id = tenancy.id
      end
      # message = conversation.tenancy_staff_messages.build({sender_id: sender_id, receiver_id: receiver_id, body: conversation_params[:body], subject: conversation_params[:subject], from: from})
      if message && message.save
        flash[:notice] = "Conversation saved!"
        redirect_to tenancy_path(tenancy)
      else
        flash[:alert] = "Server error please try again later!"
        redirect_to tenancy_path(tenancy)
      end
    else
      flash[:alert] = "No tenancy found!"
      redirect_to tenancy_path(tenancy)
    end
  end

  private
    def conversation_params
      params.permit(:tenancy_id, :subject, :body)
    end
end

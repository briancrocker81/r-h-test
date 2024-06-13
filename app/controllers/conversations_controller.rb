class ConversationsController < ApplicationController
  before_action :authenticate_user!

  # def index
  #   @conversations = Conversation.where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id)
  #   @users = User.where.not(id: current_user.id)
  # end

  def create
    property = Property.find conversation_params[:property_id]
    if property.present?
      conversation = Conversation.create!({property_id: property.id})
      message = conversation.messages.build({sender_id: current_user.id, receiver_id: current_user.id, body: conversation_params[:body]})
      if message.save
        flash[:notice] = "Conversation saved!"
        redirect_to property_path(property)
      else
        flash[:alert] = "Server error please try again later!"
        redirect_to property_path(property)
      end
    else
      flash[:alert] = "No property found!"
      redirect_to property_path(property)
    end
  end

  private
    def conversation_params
      params.permit(:property_id, :body)
    end  
end

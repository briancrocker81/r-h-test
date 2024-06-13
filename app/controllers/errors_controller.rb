class ErrorsController < ApplicationController
  layout :set_tenancy_layout
  
	before_action :authenticate_user!, except: [:index]
  def index
    @code = params[:code].present? ? params[:code] : 404
    @message = params[:message].present? ? params[:message] : "No message!"
  end

  private
    def set_tenancy_layout
      "tenancy_dashboard"
    end
end

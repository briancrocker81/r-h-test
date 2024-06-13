class AttachmentsController < ApplicationController
  before_action :find_attachable
  
  def create
    @attachable.attachments.create attachment_params
    redirect_to @attachable
  end
  
  private
  
  def attachment_params
    params.require(:attachment).permit(:attachment)
  end
  
  # could be improve and include into concerns
  # http://api.rubyonrails.org/classes/ActiveSupport/Concern.html
  def find_attachable
    params.each do |name, value|
      return @attachable = $1.classify.constantize.find(value) if name =~ /(.+)_id$/
    end
  end
end
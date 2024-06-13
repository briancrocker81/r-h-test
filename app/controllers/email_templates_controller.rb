class EmailTemplatesController < ApplicationController
  def index
    @templates = EmailTemplate.build_or_initialize_templates
  end

  def edit
    @template = EmailTemplate.find_or_initialize_by(template_name: params[:template_name]) 
  end

  def update
    @template = EmailTemplate.find_or_initialize_by(template_name: params[:template_name]) 
    @template.update(permitted_params)
    if @template.save
      flash[:notice] = 'Email template updated' 
      redirect_to admin_email_templates_path
    else
      render :edit
    end
  end

  def destroy
    @template = EmailTemplate.find_by(template_name: params[:template_name]) 
    if @template.destroy
      flash[:notice] = 'Email template was reset' 
    else
      flash[:alert] = 'Unable to reset email template, please contact support' 
    end
    redirect_to admin_email_templates_path
  end

  private

  def permitted_params
    params.require(:email_template).permit(:content)
  end
end

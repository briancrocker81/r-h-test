class AdminsController < ApplicationController

  before_action :set_generic_document, only: %w(edit_generic_document update_generic_document destroy_generic_document assign_generic_document)

  ## admin
  def index
  end

  ## generic documents
  def generic_document
    @generic_documents = GenericDocument.all
    @generic_document = @generic_documents.count < 3 ? GenericDocument.new : GenericDocument.last
  end

  def system_signature

  end

  ## new generic documents
  def new_generic_document
    @generic_document = GenericDocument.new
  end

  ## edit generic documents
  def edit_generic_document
  end

  ## create generic documents
  def create_generic_document
    errors = []
    params[:document_name].each_with_index do |name, i|
      generic_document = GenericDocument.new(document_file: params[:document_file][i], document_name: params[:document_name][i], document_expiry: params[:document_expiry][i], admin: current_user)
      unless generic_document.save
        errors << generic_document.errors.full_messages
      end
    end
    if errors.count > 0
      @errors = errors.uniq.join(', ')
    else
      @message = 'Documents has been uploaded successfully!'
    end
    @generic_documents = GenericDocument.all
  end

  ## update generic documents
  def update_generic_document
    errors = []
    if params[:id].present?
      params[:id].each_with_index do |id, i|
        generic_document = GenericDocument.find_by(id: id)
        generic_document = generic_document ? generic_document : GenericDocument.new
        generic_document.document_name = params[:document_name][i]
        generic_document.document_file = params[:document_file][i] if params[:document_file].present? && params[:document_file][i].present? && (params[:document_file][i].class != NilClass)
        generic_document.document_expiry = params[:document_expiry][i]
        generic_document.admin_id = current_user.id
        unless generic_document.save
          errors << generic_document.errors.full_messages
        end
      end
    else
      params[:document_name].each_with_index do |name, i|
        unless params[:id][i]
          generic_document = GenericDocument.new(document_file: params[:document_file][i], document_name: params[:document_name][i], document_expiry: params[:document_expiry][i], admin: current_user)
          unless generic_document.save
            errors << generic_document.errors.full_messages
          end
        end
      end
    end
    if errors.count > 0
      @errors = errors.uniq.join(', ')
    else
      @message = 'Documents has been updated successfully!'
    end
    @generic_documents = GenericDocument.all
  end

  ## destroy generic documents
  def destroy_generic_document
    @generic_document.destroy
    @generic_documents = GenericDocument.all
    @message = 'Document has been deleted and deallocated from the property documents successfully!'
  end

  ## assign generic documenrs to all properties
  def assign_generic_document
    Property.all.each do |property|
      compliance_document = property.compliance_documents.find_or_initialize_by(document_name: @generic_document.document_name)
      compliance_document.document_expiry = @generic_document.document_expiry
      compliance_document.document_file = @generic_document.document_file
      compliance_document.generic_document_id = @generic_document.id
      compliance_document.save
    end
    redirect_to generic_document_path, notice: 'Document was assigned to all properties!'
  end

  ## manage automation mail
  def manage_automation_mail
    @manage_automation_mails = ManageAutomationMail.all
    @manage_automation_mail = ManageAutomationMail.new
  end

  ## open automation mail modal
  def open_automation_mail
    @tag = params[:tag]
    @manage_automation_mail = params[:id] ? ManageAutomationMail.find_by(id: params[:id]) : ManageAutomationMail.new
    @url = @tag == 'new' ? create_manage_automation_mail_admin_path : update_manage_automation_mail_admin_path(@manage_automation_mail)
    @options = ManageAutomationMail::AUTOMATION_MAILS.map { |mail|
      mail.delete(' ').constantize.action_methods.to_a
    }.flatten
  end

  ## get dependent options
  def get_mail_options
    @mail_methods = params[:mail].delete(' ').constantize.action_methods.to_a
    render json: { options: @mail_methods }
  end

  ## delete automation mail
  def delete_automation_mail
    @automation_mail = ManageAutomationMail.find_by(id: params[:id])
    if @automation_mail.destroy
      flash[:notice] = "Setting has been destroyed!"
    else
      flash[:alert] = "Something went wrong!"
    end
    redirect_to manage_automation_mail_admin_path
  end

  ## create manage autoation mail
  def create_manage_automation_mail
    @manage_automation_mail = ManageAutomationMail.new
    @manage_automation_mail = ManageAutomationMail.new(manage_automation_mail_params)
    if @manage_automation_mail.save
      flash[:notice] = 'Setting has been created successfully!'
    else
      flash[:alert] = @manage_automation_mail.errors.full_messages.join(', ')
    end
    redirect_to manage_automation_mail_admin_path
  end

  ## update automation mail
  def update_manage_automation_mail
    @manage_automation_mail = ManageAutomationMail.find_by(id: params[:id])
    if @manage_automation_mail.update(manage_automation_mail_params)
      flash[:notice] = 'Setting has been created successfully!'
    else
      flash[:alert] = @manage_automation_mail.errors.full_messages.join(', ')
    end
    redirect_to manage_automation_mail_admin_path
  end

  ## update automation mail status
  def update_manage_automation
    @manage_automation_mail = ManageAutomationMail.find_by(id: params[:id])
    if @manage_automation_mail.update(automation: params[:automation])
      flash[:notice] = 'Setting has been created successfully!'
    else
      flash[:alert] = @manage_automation_mail.errors.full_messages.join(', ')
    end
    redirect_to manage_automation_mail_admin_path
  end

  ## properties_sync_setting
  def sync_setting
    @admin_variable = AdminVariable.last || AdminVariable.new
  end

  def update_sync_setting
    @admin_variable = params[:id].present? ? AdminVariable.find_by(id: params[:id]) : AdminVariable.new
    @admin_variable.rightmove = params[:admin_variable][:rightmove]
    @admin_variable.zoopla = params[:admin_variable][:zoopla]
    @admin_variable.onthemarket = params[:admin_variable][:onthemarket]
    if @admin_variable.save
      flash[:notice] = "Sync setting has been updated successfully!"
    else
      flash[:alert] = @admin_variable.errors.full_messages.join(', ')
    end
    redirect_to sync_setting_admin_path
  end

  private

  def set_generic_document
    @generic_document = GenericDocument.find_by(id: params[:id])
    redirect_to generic_document_admin_path, alert: 'Document was not found!' if @generic_document.blank?
  end

  def manage_automation_mail_params
    params[:manage_automation_mail][:mail_methods] = params[:manage_automation_mail][:mail_methods].reject(&:empty?)
    params.require(:manage_automation_mail).permit(:mail_type, :automation, mail_methods: [])
  end

end

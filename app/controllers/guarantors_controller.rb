class GuarantorsController < ApplicationController
  layout "guarantor_dashboard"
  before_action :set_guarantor_for_u_id, only: [ :guarantor_dashboard, :agreement_form, :submit_agreement_form, :tenancy_agreement_form, :confirm_tenancy_signed, :complete_guarantor_agreement]
  before_action :authenticate_user!, except: [ :guarantor_dashboard, :agreement_form, :submit_agreement_form, :tenancy_agreement_form, :complete_guarantor_agreement, :confirm_tenancy_signed ]

  def guarantor_dashboard
  end

  def agreement_form
  end

  def submit_agreement_form
    if @guarantor.update(agreement_params.merge({validate_guarantor_dashboard: true}))
      flash[:notice] = "Successfully submited agreement details!"
      redirect_to guarantor_dashboard_path(@guarantor.uri_string)
    else
      @errors = @guarantor.errors.full_messages.join(', ')
      render 'agreement_form'
    end
  end

  def tenancy_agreement_form
    @tenancy = @guarantor.tenancy
  end

  def confirm_tenancy_signed
    @tenancy = @guarantor.tenancy
    if @guarantor.update(confirm_signed_tenancy: params[:guarantor][:confirm_signed_tenancy], validate_guarantor_confirmed: true)
      redirect_to guarantor_dashboard_path(@guarantor.uri_string), notices: 'Seen and confirmed the tenancy signed!'
    else
      flash[:alert] = @guarantor.errors.full_messages.join(', ')
      render 'tenancy_booking_form'
    end
  end

  def complete_guarantor_agreement
    tenancy = @guarantor.tenancy
    @guarantor.update_column(:complete_guarantor_agreement, true)
    # tenancy.update(booking_status: 'complete') if @guarantor.complete_guarantor_agreement && tenancy.final_submission
    TenancyMailer.send_guarantor_completed_mail(@guarantor.id)
    GuarantorMailer.send_guarantor_completed_mail(@guarantor.id).deliver_now
    redirect_to guarantor_dashboard_path(@guarantor.uri_string), notices: 'Successfully completed guarantor agreement details!'
  end

  def mail_guarantor_dashboard_link
    guarantor = Guarantor.find_by(uri_string: params[:u_id])
    GuarantorMailer.send_dashboard_link(guarantor.id).deliver_now if guarantor.present? && guarantor.guarantor_email.present?
    redirect_to tenancy_path(guarantor.tenancy), notice: "Dashboard link has been sent to the guarantor!"
  end

  private
    def agreement_params
      params.require(:guarantor).permit(:guarantor_name, :guarantor_address, :guarantor_post_code,
                                        :guarantor_email, :guarantor_mobile, :guarantor_relationship, :own_property,
                                        :national_insurance_number, :contact_number, :date_of_birth, :tenant_relationship,
                                        :employment_status, :employer_name, :employer_manager, :employer_contact,
                                        :employer_address, :employer_email, :job_title, :net_salary, :photo_id,
                                        :utility_bill, :guarantor_signature, :confirm_guarantor)
    end

    def set_guarantor_for_u_id
      @guarantor = valid_uri?
    end

    def valid_uri?
      guarantor = Guarantor.find_by(uri_string: params[:u_id])
      if guarantor.present?
        return guarantor
      else
        @message = "Mis match in u_id or Please contact customer service for more information, Thank you for your patience."
        redirect_to errors_path(code:404,message: @message)
      end
    end
end

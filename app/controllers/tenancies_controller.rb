class TenanciesController < ApplicationController
  require 'csv'

  # Ideally these would be in a different controller
  # but we dont currently have the time or patience to move them
  DASHBOARD_METHODS = %i[tenancy_dashboard booking_form submit_booking_form agreement_form submit_agreement_form document_confirmation_form document_confirmation final_submission closed_dashboard]

  layout :set_tenancy_layout
  before_action :set_tenancy, only: [:edit, :update, :archived, :complete, :roll_next_year, :send_payment_items, :tenancy_payment_schedule]
  before_action :set_tenancy_for_u_id, only: DASHBOARD_METHODS
  before_action :authenticate_user!, except: DASHBOARD_METHODS
  before_action :redirect_away_if_booking_race_lost, only: DASHBOARD_METHODS - [:closed_dashboard]
  include Pagy::Backend
  # GET /tenancies
  # GET /tenancies.json

  def closed_dashboard
  end

  def index
    @tenancies = Tenancy.unscoped.includes(room: :property).all
    @filterrific = initialize_filterrific(
      @tenancies,
      params[:filterrific],
      select_options: {
        sorted_by: @tenancies.options_for_sorted_by
      },
      persistence_id: "tenancy_key",
      default_filter_params: {},
      sanitize_params: true,
      ) || return
    @pagy, @tenancies = pagy(@filterrific.find, items: 200)
    @archived = params[:archived]
    @tenancies = params[:archived] ? @tenancies.unscoped.archived : @tenancies.unscoped.not_archived
    respond_to do |format|
      format.html
      format.js
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"tenancies.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  # GET /tenancies/1
  # GET /tenancies/1.json
  def show
    id = params[:id] ? params[:id] : params[:tenancy_id]

    # Tenancy clone
    # @tenancy = params[:archived] ? Tenancy.unscoped.find_by(id: id) : Tenancy.find_by(id: id)
    # @history = @tenancy.tenancy_histories.unscoped.where(tenancy_id: @tenancy.id).or(@tenancy.tenancy_histories.unscoped.where(original_id: @tenancy.id))
    # # @history = @tenancy.tenancy_histories.unscoped.all.map{|t| [t.tenancy_id, t.original_id ]}
    #

    # @tenancy = params[:archived] ? Tenancy.unscoped.find_by(id: id) : Tenancy.find_by(id: id)
    @tenancy = Tenancy.unscoped.find_by(id: id)
    @archived = params[:archived]

    redirect_to (@archived ? tenancies_path(@tenancy, archived: @archived) : tenancies_path(@tenancy)), alert: 'Tenancy not found' if @tenancy.blank?
    @properties = Property.all.map{|p| [p.property_name,p.id ]}
  end

  # GET /tenancies/new
  def new
    @tenancy = Tenancy.new
    @tenancy_identifications = @tenancy.tenancy_identifications.build
    @tenancy_documents = @tenancy.tenancy_documents.build
  end

  # GET /tenancies/1/edit
  def edit
    if @tenancy.is_guarantor_available
      @tenancy.guarantor.present? ? @tenancy.guarantor : @tenancy.build_guarantor
    end
    if @tenancy.tenancy_is == 0
      @tenancy.student_course_detail.present? ? @tenancy.student_course_detail : @tenancy.build_student_course_detail
    else
      @tenancy.professional_detail ? @tenancy.professional_detail : @tenancy.build_professional_detail
    end
  end

  # POST /tenancies
  # POST /tenancies.json
  def create
    manage_tanancy_end_date
    @tenancy = Tenancy.new(tenancy_params)
    @uri_string = @tenancy.uri_string
    respond_to do |format|
      @tenancy.booking_status = 'complete' if params[:booking_status]
      @tenancy.payment_edit = true
      if @tenancy.save
        format.html { redirect_to @tenancy, notice: 'Tenancy was successfully created.' }
        format.json { render :show, status: :created, location: @tenancy }
      else
        format.html { render :new }
        format.json { render json: @tenancy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tenancies/1
  # PATCH/PUT /tenancies/1.json
  def update
    manage_tanancy_end_date
    set_tenancy_payment_card
    respond_to do |format|
      if @tenancy.update(tenancy_params.merge({validate_doc: false}))
        @tenancy.booking_status = 'complete' if params[:booking_status]
        @tenancy.payment_edit = true
        @tenancy.save
        format.html { redirect_to @tenancy, notice: 'Tenancy was successfully updated.' }
        format.json { render :show, status: :ok, location: @tenancy }
      else
        format.html { render :edit }
        format.json { render json: @tenancy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tenancies/1
  # DELETE /tenancies/1.json
  def destroy
    # @tenancy.destroy
    @tenancy = Tenancy.unscoped.find(params[:id])
    if @tenancy.present?
      if @tenancy.archived?
        @tenancy.archived = false
        @tenancy.save
        @tenancy.destroy
        respond_to do |format|
          format.html { redirect_to tenancies_path(archived: true), notice: 'Tenancy was successfully destroyed.' }
          format.json { head :no_content }
        end
      else
        @tenancy.destroy
        respond_to do |format|
          format.html { redirect_to tenancies_url, notice: 'Tenancy was successfully destroyed.' }
          format.json { head :no_content }
        end
      end

    end

  end

  def archived
    respond_to do |format|
      @tenancy.archived = true
      if @tenancy.save(validate: false)
        format.html { redirect_to listings_path, notice: "Tenancy ID: #{@tenancy.id} - #{@tenancy.tenant_name} has been archived." }
        format.json { head :no_content }
      else
        format.html { redirect_to listings_path, notice: 'Something went wrong.' }
        format.json { head :no_content }
      end
    end
  end

  def unarchived
    id = params[:id] ? params[:id] : params[:tenancy_id]
    @tenancy = Tenancy.unscoped.find_by(id: id)
    # @tenancy = Tenancy.unscoped.find(params[:id])
    respond_to do |format|
      @tenancy.archived = false
      if @tenancy.save(validate: false)
        format.html { redirect_to tenancies_url, notice: "Tenancy ID: #{@tenancy.id} - #{@tenancy.tenant_name} has been unarchived." }
        format.json { head :no_content }
      else
        format.html { redirect_to tenancies_url, notice: 'Something went wrong.' }
        format.json { head :no_content }
      end
    end
  end

  def tenancy_dashboard
  end

  def booking_form
    @tenancy_avr = @tenancy.tenancy_payment_items.where(item: 'AvR').first
    # @student_course_detail = @tenancy.student_course_detail ? @tenancy.student_course_detail : @tenancy.build_student_course_detail if @tenancy.tenant_type == 1
    # @professional_detail = @tenancy.professional_detail ? @tenancy.professional_detail : @tenancy.build_professional_detail if @tenancy.tenant_type == 3
    @student_course_detail = @tenancy.student_course_detail ? @tenancy.student_course_detail : @tenancy.build_student_course_detail
    @professional_detail = @tenancy.professional_detail ? @tenancy.professional_detail : @tenancy.build_professional_detail
    @guarantor = @tenancy.guarantor ? @tenancy.guarantor : @tenancy.build_guarantor if @tenancy.is_guarantor_available?
  end

  def submit_booking_form
    if @tenancy.update(booking_params.merge({validate_booking: true}))
      @tenancy.update_attributes({form_submitted: true})
      flash[:notice] = "Successfully submitted your personal details!"
      redirect_to tenancy_dashboard_path(@tenancy.uri_string)
    else
      @guarantor = @tenancy.guarantor ? @tenancy.guarantor : @tenancy.build_guarantor if @tenancy.is_guarantor_available?
      # @student_course_detail =  @tenancy.student_course_detail ? @tenancy.student_course_detail : @tenancy.build_student_course_detail if @tenancy.tenant_type == 1
      @student_course_detail =  @tenancy.student_course_detail ? @tenancy.student_course_detail : @tenancy.build_student_course_detail if @tenancy.tenancy_is == 0
      # @professional_detail = @tenancy.professional_detail ? @tenancy.professional_detail : @tenancy.build_professional_detail if @tenancy.tenant_type == 3
      @professional_detail = @tenancy.professional_detail ? @tenancy.professional_detail : @tenancy.build_professional_detail if @tenancy.tenancy_is == 1
      flash[:alert] = @tenancy.errors.full_messages.join(', ')
      render 'booking_form'
    end
  end

  def agreement_form
    @tenancy_avr = @tenancy.tenancy_payment_items.where(item: 'AvR').first
    @tenancy_utilities_inc_count = @tenancy.room.property.property_utilities.where(included: true).count
    @tenancy_utilities_not_inc_count = @tenancy.room.property.property_utilities.where(included: false).count
    @tenancy_identifications = @tenancy.tenancy_identifications.build
    @company = Company.first
  end

  def submit_agreement_form
    agreement_new_params = agreement_params.merge({validate_doc: true, signed_tenancy_agreement: true})
    agreement_new_params = agreement_new_params.merge({advanced_rent_payment_date: Date.today}) if @tenancy.tenancy_is == 0 && @tenancy.advanced_rent_payment_date.blank?
    agreement_new_params = agreement_new_params.merge({deposit_date: Date.today}) if @tenancy.tenancy_is == 1 && @tenancy.deposit_date.blank?
    if @tenancy.update(agreement_new_params)
      flash[:notice] = "Successfully submitted agreement details!"
      redirect_to tenancy_dashboard_path(@tenancy.uri_string)
    else
      flash[:alert] = @tenancy.errors.full_messages.join(', ')
      render 'agreement_form'
    end
  end

  def document_confirmation_form
  end

  def document_confirmation
    if @tenancy.update(doc_params.merge({validate_doc: true}))
      flash[:notice] = "Successfully submitted your compliance document!"
      redirect_to tenancy_dashboard_path(@tenancy.uri_string)
    else
      flash[:alert] = @tenancy.errors.full_messages.join(', ')
      render 'document_confirmation_form'
    end
  end

  def final_submission
    if @tenancy.set_final_submission!
      flash[:notice] = "Successfully submitted your compliance documents! You will receive a confirmation email shortly."
    else
      flash[:alert] = @tenancy.errors.full_messages.join(', ')
    end
    redirect_to tenancy_dashboard_path(@tenancy.uri_string)
  end

  def mail_tenancy_dashboard_link
    @tenancy = Tenancy.find params[:tenancy_id]
    if @tenancy.send_tenancy_dashboard_link
      flash[:notice] = "Dashboard link has been mailed to tenant"
      redirect_back(fallback_location: root_path)
    else
      flash[:notice] = "Unable to mail tenant, please contact the administrator"
      redirect_back(fallback_location: root_path)
    end
  end

  def tenancy_payment_item_form
    @tenancy = Tenancy.find params[:tenancy_id]
    if !params[:item_id].nil? && params[:item_id] != ''
      @tenancy_payment_item = TenancyPaymentItem.find params[:item_id]
    else
      @tenancy_payment_item = TenancyPaymentItem.new
    end
  end
  def update_total_value
    total_amount_due = 0
    @tenancy.tenancy_payment_items.each do |pay_item|
      total_amount_due += pay_item.amount_due
    end
    @tenancy.update_column(:total_tenancy_value, total_amount_due)
  end
  def tenancy_payment_item
    @tenancy = Tenancy.find params[:tenancy_id]
    if !params[:item_id].nil? && params[:item_id] != ''
      tenancy_payment_item = TenancyPaymentItem.find params[:item_id]
      tenancy_payment_item.update(tenancy_payment_item_params)
      update_total_value
      flash[:notice] = "Successfully updated payment item!"
    else
      if @tenancy.deposit_term == "monthly" || @tenancy.rent_payment_option == 1 || @tenancy.rent_payment_option == "1"
        item_type = 'monthly'
      elsif @tenancy.deposit_term == "termly" || @tenancy.rent_payment_option == 0 || @tenancy.rent_payment_option == "0"
        item_type = 'termly'
      elsif @tenancy.deposit_term == "full" || @tenancy.rent_payment_option == 2 || @tenancy.rent_payment_option == "2"
        item_type = 'full'
      else
        item_type = 'monthly'
      end
      @tenancy_payment_item = @tenancy.tenancy_payment_items.new(tenancy_payment_item_params.merge!(item_type: item_type, item_year: @tenancy.year))
      flash[:notice] = @tenancy_payment_item.save ? "Successfully added new payment item!" : @tenancy_payment_item.errors.full_messages.join(', ')
    end
    redirect_to tenancy_path(@tenancy.id)
  end

  def tenancy_payment_item_delete
    tenancy_payment_item = TenancyPaymentItem.find params[:item_id]
    tenancy = tenancy_payment_item.tenancy
    if tenancy_payment_item.destroy
      flash[:notice] = "Successfully deleted payment item"
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to tenancy_path(tenancy.id)
  end

  def complete
    @tenancy.booking_status = 'complete'
    @tenancy.save(validate: false)
    redirect_to tenancy_path(@tenancy), notice: 'Your tenancy was successfully completed!'
  end

  def roll_next_year
    @tenancy = Tenancy.unscoped.find(params[:id])
    @tenancy.roll_into_next_year = true
    @tenancy.rolled = true
    old_start_date = @tenancy.tenancy_start.year + 1
    old_end_date = @tenancy.tenancy_end.year + 1
    last_year = @tenancy.year
    year = last_year.split('/')
    dup_tenant = @tenancy.amoeba_dup
    dup_tenant.booking_status = 'complete'
    dup_tenant.tenancy_start = "#{old_start_date}-09-01"
    dup_tenant.tenancy_end = "#{old_end_date}-08-31"
    dup_tenant.roll_into_next_year = 0
    dup_tenant.year = "#{year[1]}/#{year[1].to_i + 1}" if dup_tenant.tenancy_end.strftime('%Y').to_i >= year[1].to_i + 1
    dup_tenant.skip_sending_dashboard_link = true
    # add new field for old tenancy id's so we can visit old profiles if needed
    dup_tenant.save(validate: false) if dup_tenant.roll_payment_into_next_year(last_year)
    redirect_to tenancy_path(dup_tenant), notice: 'This tenancy has been rolled into the next year!'

  end

  ## send payment items to tenant
  def send_payment_items
    TenancyMailer.send_payment_items(@tenancy.id).deliver_now
    redirect_to tenancy_path(@tenancy), notice: 'Mail has been sent successfully!'
  end

  def tenancy_payment_schedule
    file = TenancyPaymentSchedulePdf.new(@tenancy).render
    send_data(file, filename: "tenancy_payment_schedule.pdf", type: "application/pdf", disposition: "inline")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def tenancy_payment_item_params
      params.require(:tenancy_payment_item).permit(:item, :due_date, :amount_paid, :amount_due, :payment_method, :date_paid)
    end

    def set_tenancy
      id = params[:id] ? params[:id] : params[:tenancy_id]
      @tenancy = Tenancy.find_by(id: id)
      redirect_to tenancies_path, alert: 'Tenancy not found!' if @tenancy.blank?
    end

    def set_tenancy_for_u_id
      @tenancy = valid_uri?
    end

    def set_tenancy_layout
      (DASHBOARD_METHODS.include? params[:action].to_sym) ? "tenancy_dashboard" : "application"
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def tenancy_params
      params.require(:tenancy).permit(:room_id, :tenancy_rate, :rate, :tenant_type, :address, :state, :city,
                                      :tenancy_start, :tenancy_end, :first_name, :surname, :dob, :mobile, :email,
                                      :nationality, :criminal_record, :accept_agreement, :year, :emergency_contact_name,
                                      :emergency_contact_number, :emergency_contact_address, :emergency_contact_postcode,
                                      :advanced_rent_payment_amount, :number_of_payments, :total_tenancy_value,
                                      :payment_amount,  :deposit_guarantor_amount, :deposit_date, :weekly_price,
                                      :monthly_price, :advanced_rent_payment_date, :payment_card_pan,
                                      :payment_card_expiry, :payment_card_cvc, :secondary_contact_first_name,
                                      :rent_due_date, :rent_installment_term, :secondary_contact_last_name,
                                      :secondary_contact_phone_number, :secondary_contact_email, :read_doc,
                                      :rent_payment_option, :signed_tenancy_agreement, :number_of_weeks,
                                      :final_submission, :number_of_months, :booking_status, :payment_status,
                                      :form_submitted, :signed_tenancy_agreement, :read_doc, :rent_payment_option,
                                      :deposit_date, :deposit_paid, :deposit_protected, :prescribed_info_sent,
                                      :special_conditions, :tenancy_agreement_signature, :confirmed_video_viewed,
                                      :initial_payment, :initial_payment_paid, :initial_payment_date, :tenancy_is,
                                      term_due_dates: {},
                                      criminal_records_attributes: [:id, :conviction_status, :offence, :date, :judgement, :_destroy],
                                      tenancy_documents_attributes: [:id, :document_file, :document_name, :verified, :staff_id, :_destroy],
                                      tenancy_identifications_attributes: [:id, :id_proof_doc, :id_proof_name, :verified, :staff_id, :_destroy],
                                      guarantor_attributes: [:id, :guarantor_name, :guarantor_address, :guarantor_post_code, :guarantor_email, :guarantor_mobile,
                                                             :guarantor_relationship, :own_property,
                                                             :national_insurance_number, :contact_number,
                                                             :date_of_birth, :tenant_relationship, :employment_status,
                                                             :employer_name, :employer_manager, :employer_contact,
                                                             :employer_address, :employer_email, :job_title, :net_salary,
                                                             :confirm_guarantor, :confirm_signed_tenancy, :complete_guarantor_agreement,
                                                             :_destroy],
                                      student_course_detail_attributes: [:id, :studying_at, :student_id_number,
                                                                         :course, :course_start, :course_end, :_destroy],
                                      professional_detail_attributes: [:id, :working_at, :job_title, :salary,
                                                                       :salary_type, :employment_type, :receive_benefits,
                                                                       :benefit_details, :_destroy],
                                      tenancy_history_attributes: [:id, :tenancy_id, :original_id, :_destroy],
                                      additional_tenants_attributes: [:id, :first_name, :surname, :phone_number,
                                                                      :address, :email, :signed_date, :accept_agreement,
                                                                      :_destroy])
    end

    def booking_params
      params.require(:tenancy).permit(:first_name, :surname, :dob, :mobile, :email, :address, :state, :city,
                                      :nationality, :criminal_record, :accept_agreement, :year,  :emergency_contact_name,
                                      :emergency_contact_number, :emergency_contact_address, :emergency_contact_postcode,
                                      :advanced_rent_payment_amount, :advanced_rent_payment_date, :payment_card_pan,
                                      :payment_card_expiry, :signature, :confirm_tenancy, :payment_card_cvc,
                                      :advanced_rent_payment_amount, :number_of_weeks, :number_of_months, :tenancy_is,
                                      :tenant_type,
                                      :rent_payment_option, :deposit_date, :special_conditions, :initial_payment,
                                      guarantor_attributes: [:id, :guarantor_name, :guarantor_address,
                                                             :guarantor_post_code, :guarantor_email, :guarantor_mobile,
                                                             :guarantor_relationship, :_destroy],
                                      student_course_detail_attributes: [:id, :studying_at, :student_id_number,
                                                                         :validate_student, :course, :course_start,
                                                                         :course_end,:_destroy],
                                      professional_detail_attributes: [:id, :working_at, :validate_professional,
                                                                       :job_title, :salary, :salary_type,
                                                                       :employment_type, :receive_benefits,
                                                                       :benefit_details, :_destroy],
                                      criminal_records_attributes: [:id, :conviction_status, :offence, :date,
                                                                    :judgement, :_destroy],
                                      additional_tenants_attributes: [:id, :first_name, :surname, :phone_number,
                                                                      :address, :email, :signed_date, :_destroy],
                                      tenancy_identifications_attributes: [:id, :id_proof_doc, :id_proof_name, :verified, :staff_id, :_destroy])
    end

    def agreement_params
      params.require(:tenancy).permit(:accept_agreement, :address, :state, :city,:tenancy_agreement_signature,
                                      :signed_date, tenancy_identifications_attributes: [:id, :id_proof_doc,
                                                                                         :id_proof_name, :verified,
                                                                                         :staff_id, :_destroy],
                                      additional_tenants_attributes: [:id, :signed_date, :signature, :accept_agreement])
    end

    def doc_params
      params.require(:tenancy).permit(:read_doc)
    end

    def valid_uri?
      tenancy = Tenancy.find_by(uri_string: params[:u_id])
      if tenancy.present?
        tenancy.dashboard_link_visited = true
        return tenancy
      else
        @message = "There is a mis-match your data. Please contact customer service for more information, Thank you for your patience"
        redirect_to errors_path(code:404,message: @message)
      end
    end

    def manage_tanancy_end_date
      if @tenancy.nil? || (@tenancy.present? && !@tenancy.signed_tenancy_agreement?) || params[:tenancy]['tenancy_end(3i)'].blank?
        if params[:tenancy]['tenancy_start(3i)']
          end_date = Date.parse("#{params[:tenancy]['tenancy_start(3i)']}-#{params[:tenancy]["tenancy_start(2i)"]}-#{params[:tenancy]["tenancy_start(1i)"]}")
        else
          end_date = Date.today
        end
        params[:tenancy][:tenancy_end] = params[:tenancy][:number_of_weeks] ? end_date + params[:tenancy][:number_of_weeks].to_i.weeks : end_date + params[:tenancy][:number_of_months].to_i.months
      end
    end

    def set_tenancy_payment_card
      params[:tenancy][:payment_card_pan] = @tenancy.payment_card_pan if params[:tenancy][:payment_card_pan] && params[:tenancy][:payment_card_pan].include?('*')
      params[:tenancy][:payment_card_cvc] = @tenancy.payment_card_cvc if params[:tenancy][:payment_card_cvc] && params[:tenancy][:payment_card_cvc].include?('*')
    end

    def redirect_away_if_booking_race_lost
      return unless Tenancy.competing_tenancies_for(@tenancy)
                           .where(final_submission: true)
                           .exists?

      redirect_to closed_dashboard_path(@tenancy.uri_string)
    end
end

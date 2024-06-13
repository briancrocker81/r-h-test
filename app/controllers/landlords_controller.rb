class LandlordsController < ApplicationController
  before_action :set_landlord, only: [:show, :edit, :update, :destroy, :filter_booking_report, :landlord_booking_report, :send_booking_report]
  include Pagy::Backend
  require 'csv'
  require 'securerandom'

  # GET /landlords
  # GET /landlords.json
  # def index
  #   @landlords = Landlord.all
  # end

  def index
    @landlords = Landlord.joins(:property)
    @filterrific = initialize_filterrific(
      Landlord,
      params[:filterrific],
      select_options: {
        sorted_by: Landlord.options_for_sorted_by
      },
      persistence_id: "landlord_key",
      default_filter_params: {},
      sanitize_params: true,
      ) || return
    @pagy, @landlords = pagy(@filterrific.find, items: 50)

    # respond_to do |format|
    #   format.html
    #   format.js
    # end

    if params[:format].present?
      respond_to do |format|
        if params[:format] == "csv"
          format.html
          format.csv do
            headers['Content-Disposition'] = "attachment; filename=\"listings.csv\""
            headers['Content-Type'] ||= 'text/csv'
          end
        elsif params[:format] == "pdf" && params[:mail] == "false"
          format.html
          format.pdf do
            pdf = LandlordPdf.new(@landlords)
            send_data pdf.render, filename: 'landlord.pdf', type: 'application/pdf'
          end
        elsif params[:mail] == "true" && params[:format] == "pdf"
          filename = "#{"listings-"+SecureRandom.hex(8)+".pdf"}"
          format.html
          format.pdf do
            pdf = LandlordPdf.new(@landlords)
            pdf.render_file(filename)
            redirect_to(reset_filterrific_url(format: :html)) && return
          end
        end
      end
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  # GET /landlords/1
  # GET /landlords/1.json
  def show
    @landlord = Landlord.includes(properties: [rooms: [tenancies: :tenancy_documents]]).find_by(id: params[:id])
    @rooms = @landlord.rooms
    @properties = @landlord.properties
    @year = @current_year
    @let_tenancies = @landlord.tenancies.where(booking_status: [1, 2]).where(year: @year)
    @landlord_rooms = @rooms
    @total_rooms = @landlord_rooms.count.to_i
    @total_let_tenancies = @let_tenancies.count.to_i
    @property_let = @total_let_tenancies != 0 ? @total_let_tenancies * 100 / (@total_rooms || 0) : nil
    @income = TenancyPaymentItem.where(tenancy_id: @let_tenancies.ids).pluck(:amount_paid).sum(&:to_f)
  end

  def find_property
    @property = Property.find(params[:id])
  end

  # GET /landlords/new
  def new
    @landlord = Landlord.new
    @landlord_documents = @landlord.landlord_documents.build
  end

  # GET /landlords/1/edit
  def edit
  end

  # POST /landlords
  # POST /landlords.json
  def create
    @landlord = Landlord.new(landlord_params)
    respond_to do |format|
      if @landlord.save
        if params['property_id'].present?
          properties = Property.where(id: params['property_id'])
          properties.update_all(landlord_id: @landlord.id)
        end
        format.html { redirect_to @landlord, notice: 'Landlord was successfully created.' }
        format.json { render :show, status: :created, location: @landlord }
      else
        format.html { render :new }
        format.json { render json: @landlord.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /landlords/1
  # PATCH/PUT /landlords/1.json
  def update
    respond_to do |format|
      if @landlord.update(landlord_params)
        if params['property_id'].present?
          @landlord.properties.update_all(landlord_id: nil)
          properties = Property.where(id: params['property_id'])
          properties.update_all(landlord_id: @landlord.id)
        end
        format.html { redirect_to @landlord, notice: 'Landlord was successfully updated.' }
        format.json { render :show, status: :ok, location: @landlord }
      else
        format.html { render :edit }
        format.json { render json: @landlord.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /landlords/1
  # DELETE /landlords/1.json
  def destroy
    @landlord.destroy
    respond_to do |format|
      format.html { redirect_to landlords_url, notice: 'Landlord was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  ## Generate the landlord property statement
  def landlord_booking_report
    @year = params[:year] ? params[:year] : 'all'
    landlord_booking_report = LandlordBookingReportPdf.new(@landlord, @year).render
    pdf_file_name = "landlord_booking_report(#{Date.today.strftime('%d_%b_%y_%h_%m')}).pdf"
    send_data(landlord_booking_report, filename: pdf_file_name, type: "application/pdf", disposition: "inline")
  end

  ## filter landlord properties
  def filter_booking_report
    @year = params[:year]
    @year_id =  @year != 'all' ? params[:year].to_s.gsub('/', '-') : params[:year]
    @properties = @landlord.properties
    @properties = @properties.eager_load(:tenancies).where('tenancies.year = ? and tenancies.archived = ?', @year, false).uniq unless @year == 'all'
  end

  ## send booking report to landlord
  def send_booking_report
    @year = params[:year] ? params[:year] : 'all'
    LandlordMailer.send_booking_report(@year, @landlord.id).deliver_now
    redirect_to landlord_path(@landlord), notice: "Mail has been sent successfully!"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_landlord
      @landlord = Landlord.includes(properties: [rooms: :tenancies]).find_by(id: params[:id])
      redirect_to landlords_path, alert: 'Landlord had been not found!' if @landlord.blank?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def landlord_params
      params.require(:landlord).permit(:contact_name, :contact_number, :alternate_number, :email, :address,
                                       :landlord_type, :company_name, :notes, :preferred_contact_method,
                                       :date_last_contacted, :consent_for_marketing, :do_not_email, :do_not_phone,
                                       :do_not_post, :do_not_text, :partnership_format, :rate, :fee, :account_name,
                                       :bank_name, :bank_address, :bank_sort_code, :bank_account_number,
                                       :alternate_name, :alternate_email, :iban, :bic, :pay_direct, :send_report,
                                       landlord_documents_attributes: [:id, :document_file, :document_name, :_destroy],
                                       )
    end
end

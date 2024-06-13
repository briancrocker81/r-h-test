class PropertiesController < ApplicationController
  require 'csv'
  before_action :set_property, only: [:show, :edit, :update, :destroy, :filter_landlord_statement, :resend_statement_report, :generate_landlord_annual_statement]
  before_action :admin_variable, only: [:create, :update]
  # after_create :create_associated_rooms, on: :create
  helper_method :create_associated_rooms
  include Pagy::Backend
  include PropertiesHelper
  include RoomsHelper
  include ActionView::Helpers::NumberHelper

  # GET /properties
  # GET /properties.json
  def index
    @properties = Property.includes(rooms: :tenancies)

    @filterrific = initialize_filterrific(
      @properties,
      params[:filterrific],
      select_options: {
        sorted_by: @properties.options_for_sorted_by
      },
      persistence_id: "properties_key",
      default_filter_params: {},
      sanitize_params: true,
      ) || return

    @properties = @filterrific.find

    respond_to do |format|
      format.js { paginate_and_respond(50) }
      format.html { paginate_and_respond(50) }
      format.csv { download_csv }
    end

  rescue ActiveRecord::RecordNotFound => e
    reset_filterrific_params(e)
  end

  # GET /properties/1
  # GET /properties/1.json
  def show
    @year = @current_year
    @year_id =  @current_year.to_s.gsub('/', '-')
    @rooms = @property.rooms.order(:number)
    # condition = "tenancy_start BETWEEN '#{Date.parse('01-09-20' + @year_id.split('-')[0].to_s)}' AND '#{Date.parse('31-08-20' + @year_id.split('-')[1].to_s)}'"
    @tenancies = @property.tenancies.not_archived.where(year: @year).order(:tenancy_start).group_by(&:room_id)
    @property_expenses = @property.property_expenses.where('year = ?', @year)
    @landlord_statement_reports = @property.reports.includes(:landlord).where(report_type: 'landlord_statement').where('year = ?', @year)
  end

  def get_filter_rooms
    @property = Property.find_by(id: params[:property_id])
    @year = params[:year] ? params[:year] : @current_year
    @year_id =  @year.to_s.gsub('/', '-')
    @rooms = @property.rooms.order(:number)
    @tenancies = @property.tenancies.not_archived
    # condition = "tenancy_start BETWEEN '#{Date.parse('01-09-20' + @year_id.split('-')[0].to_s)}' AND '#{Date.parse('31-08-20' + @year_id.split('-')[1].to_s)}'"
    # @tenancies = @tenancies.where(condition).group_by(&:room_id)
    @tenancies = @tenancies.where(year: @year).group_by(&:room_id)
    @rooms = @rooms.order(:number)
  end

  # GET /properties/new
  def new
    @property = Property.new
    @property.features.build
    @attachments = @property.attachments.build
    @compliance_documents = @property.compliance_documents.build
    @property_list_student = @property.build_property_list_student
    @property_list_graduate = @property.build_property_list_graduate
    @property_list_professional = @property.build_property_list_professional
    @property_list_family = @property.build_property_list_family
    generic_documents
    @property.build_listing_locations
    @property.build_service_utilities
  end

  # GET /properties/1/edit
  def edit
    @property_list_student = @property.build_property_list_student if @property.property_list_student.nil?
    @property_list_graduate = @property.build_property_list_graduate if @property.property_list_graduate.nil?
    @property_list_professional = @property.build_property_list_professional if @property.property_list_professional.nil?
    @property_list_family = @property.build_property_list_family if @property.property_list_family.nil?
    @property.build_listing_locations
    @property.build_service_utilities
    generic_documents
  end

  # POST /properties
  # POST /properties.json
  def create
    @property = Property.new(property_params)
    respond_to do |format|
      if @property.save
        if property_params[:rental_type] == "1"
          (1..property_params[:number_of_bedrooms].to_i).each do |v|
            agent_ref = (0...8).map { (65 + rand(26)).chr }.join
            act_room = @property.rooms.create({number: v, description: "", list_price: params[:room_price], agent_ref: agent_ref})
            # rightmove_response = act_room.create_rightmove
            # act_room.update_attributes(rightmove_response: rightmove_response)
          end

          @property.rooms.create({number: params[:number], description: params[:description], list_price: params[:list_price], ensuite: params[:ensuite]})
        end
        create_compliance_documents(params[:ids])
        if !params["property"]["attachment"].nil?
          params["property"]["attachment"].each do |image|
            @property.attachments.create({title: image.original_filename.split('.')[0], attachment: image.tempfile })
          end
        end
        # @property.rooms.each do |room|
        #   SyncPropertyToRightmoveJob.perform_later(room.id) if @admin_variable.rightmove
        #   SyncPropertyToZooplaJob.perform_later(room.id) if @admin_variable.zoopla
        # end
        format.html { redirect_to @property, notice: 'Property was successfully created.' }
        format.json { render :show, status: :created, location: @property }
      else
        @property.build_listing_locations
        @property.build_service_utilities
        generic_documents
        format.html { render :new }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /properties/1
  # PATCH/PUT /properties/1.json
  def update
    respond_to do |format|
      if @property.update_attributes(property_params)
        if property_params[:property_list_student_attributes][:remove_front_photo]
          @property.property_list_student.remove_front_photo!
        end
        # if property_params[:rental_type] == "1"
        #   if property_params[:number_of_bedrooms].to_i > @property.rooms.count
        #     last_room_number = @property.rooms.count
        #     extra_room_to_be_add = property_params[:number_of_bedrooms].to_i - last_room_number
        #     (1..extra_room_to_be_add).each do |v|
        #       agent_ref = (0...8).map { (65 + rand(26)).chr }.join
        #       act_room = @property.rooms.create({number: last_room_number+v, description: "", list_price: params[:room_price], agent_ref: agent_ref})
        #       rightmove_response = act_room.create_rightmove
        #       act_room.update_attributes(rightmove_response: rightmove_response)
        #     end
        #   end
        #   #@property.rooms.create({number: params[:number], description: params[:description], list_price: params[:list_price], ensuite: params[:ensuite]})
        # end
        # @property.rooms.each do |p_room|
        #   rightmove_response = p_room.create_rightmove
        #   p_room.update_attributes(rightmove_response: rightmove_response)
        # end
        create_compliance_documents(params[:ids])
        if !params["property"]["attachment"].nil?
          params["property"]["attachment"].each do |image|
            @property.attachments.create({title: image.original_filename.split('.')[0], attachment: image.tempfile })
          end
        end
        # @property.rooms.each do |room|
          # rightmove = zoopla = {}
          # rigtmove = JSON.parse(room.rightmove_response['create']) if room.rightmove_response.present?
          # zoopla = JSON.parse(room.zoopla_response['create']) if room.zoopla_response.present?
          # SyncPropertyToRightmoveJob.perform_later(room.id) if @admin_variable.rightmove && ((rightmove.present? && rightmove['success'] == false) || rightmove.blank?)
          # SyncPropertyToZooplaJob.perform_later(room.id) if @admin_variable.zoopla && ((zoopla.present? && zoopla['status'] == 'FAILED') || zoopla.blank?)
        # end
        format.html { redirect_to @property, notice: 'Property was successfully updated.' }
        format.json { render :show, status: :ok, location: @property }
      else
        @property.build_listing_locations
        @property.build_service_utilities
        format.html { render :edit }
        format.json { render json: @property.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.json
  def destroy
    @property.destroy
    respond_to do |format|
      format.html { redirect_to properties_url, notice: 'Property was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  ## Get properties by rooms
  def get_properties
    common_search_properties
    selected_properties = params['selected_properties']
    data = properties_filter(selected_properties, @properties)
    respond_to do |format|
      format.json { render json: data }
    end
  end

  ## get properties by room and selected year
  def get_available_properties
    common_search_properties
  end

  def get_rooms
    @property = Property.find(params[:property_id])
    rental_type = 'home'
    if @property.rental_type==1
      data = @property.rooms.map{|p| [p.number+', '+p.description, p.id ]}
      rental_type = 'room'
    end
    respond_to do |format|
      format.json { render :json  => { :data => data, :rental_type => rental_type } }
    end
  end

  def set_tenancy_form
    @property = Property.find params[:property_id]
    if @property.present?
      if !params[:room_id].nil?
        @room = Room.find params[:room_id]
        @tenancy = Tenancy.new
      end
    else
      flash[:alert] = "No property found!"
      redirect_to properties_path
    end
  end

  def set_tenancy
    @property = Property.find params[:property_id]
    if @property.present?
      manage_tanancy_end_date
      params[:tenancy][:rent_due_date] = "#{params[:tenancy][:rent_due_date]}/ #{params[:tenancy]['tenancy_start(2i)']}/#{params[:tenancy]['tenancy_start(1i)']}" if params[:tenancy][:rent_due_date]
      @tenancy = Tenancy.new(tenancy_params.merge!(room_id: params[:room_id]))
      @uri_string = @tenancy.uri_string
      if @tenancy&.tenancy_is != 0
        @tenancy.advanced_rent_payment_amount = 0
        @tenancy.advanced_rent_payment_date = nil
      end
      @tenancy.skip_sending_dashboard_link = params[:email_form] ? false : true
      @tenancy.payment_edit = true
      if @tenancy.save
        flash[:notice] = "Successfully created tenancy!"
      else
        flash[:alert] = @tenancy.errors.full_messages.join(', ')
      end
    else
      flash[:alert] = "No property found!"
    end
    redirect_back fallback_location: root_path
  end

  def send_email_to_tenants
    @property = Property.find(params[:id])
    @tenants_emails = @property.tenancies.not_archived.where(booking_status: 2).where(year: @current_year).pluck(:email)

    bcc_param = "bcc=#{URI.encode(@tenants_emails.join(','))}"
    render js: "window.location.href = 'mailto:?#{bcc_param}';"
  end

  def remove_property_image
    property = Property.find params[:property_id]
    @attachment = Attachment.find params[:id]
    if @attachment.destroy
      flash[:notice] = "Successfully removed property image!"
      redirect_to property_path(property.id)
    end
  end

  def edit_attachment
    @property = Property.includes(rooms: :tenancies).find_by(id: params[:property_id])
    @attachment = @property.attachments.find_by(id: params[:id])
  end

  def update_attachment
    @property = Property.includes(rooms: :tenancies).find_by(id: params[:property_id])
    @attachment = @property.attachments.find_by(id: params[:id])
    @attachment.update(alt_tag: params[:attachment][:alt_tag], title: params[:attachment][:title])
  end

  ## get year wise statement
  def filter_landlord_statement
    @year = params[:year] ? params[:year] : @current_year
    @landlord_statement_reports = @property.reports.monthly.landlord_statement
    if @year.present?
      @year_id = params[:year].to_s.gsub('/', '-')
      @landlord_statement_reports = @landlord_statement_reports.where('year = ?', @year)
    else
      @year_id = @year
    end
  end

  ## resent the statment report
  def resend_statement_report
    landlord_statement_report = Report.landlord_statement.find_by(id: params[:landlord_statement_report_id])
    LandlordMailer.send_statement_report_mail(landlord_statement_report.id).deliver_now if landlord_statement_report
    redirect_to property_path(@property), notice: 'Resent the mail to landlord'
  end

  ## generate report on date range
  def generate_landlord_annual_statement
    errors = []
    begin
      start_date = params[:start_date]
      end_date = params[:end_date]

      # Property.joins(:landlord, :property_expenses, rooms: :tenancies).uniq.each do |property|
      p "====#{@property&.property_name}====="
      date = start_date.to_date
      year = date.strftime('%y').to_i
      month = date.strftime('%m').to_i
      statement_year = month < 9 ? "#{year-1}/#{year}" : "#{year}/#{year+1}"
      report = LandlordAnnualStatementReportPdf.new(@property.id, start_date, end_date).render
      file = StringIO.new(report) #mimic a real upload file
      file.class.class_eval { attr_accessor :original_filename, :content_type } #add attr's that paperclip needs
      file.original_filename = "#{@property&.property_name}.pdf"
      file.content_type = "application/pdf"
      @property.reports.yearly.landlord_statement.where(landlord_id: @property&.landlord&.id).destroy_all
      landlord_report = @property.reports.new(report: file, landlord_id: @property&.landlord&.id, year: statement_year, month: month, report_type: 'landlord_statement', term_type: 'yearly')
      landlord_report.save
    rescue Exception => e
      puts e.message
      errors << e.message
    end
    flash[:notice] = "The annual landlord statement report has been generated successfully!"
    render json: { errors: errors }
  end

  private

  def paginate_and_respond(items_per_page)
    @pagy, @properties = pagy(@properties, items: items_per_page)
  end

  def download_csv
    headers['Content-Disposition'] = "attachment; filename=\"properties.csv\""
    headers['Content-Type'] ||= 'text/csv'
  end

  def reset_filterrific_params(exception)
    puts "Had to reset filterrific params: #{exception.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end
  def set_property
    @property = Property.includes(:property_expenses, rooms: :tenancies).find_by(id: params[:id])
    redirect_to root_path, alert: 'This property was not found!' if @property.blank?
  end

  def set_property_for_mail
    @property = Property.find(params[:property_id])
  end

  def room_params
    params.require(:room).permit(:number, :description, :list_price, :landlord_id, :ensuite)
  end

  def property_params
    params[:property][:property_listing_locations_attributes].each do |k,v|
      value = params[:property][:property_listing_locations_attributes][k][:_destroy]
      params[:property][:property_listing_locations_attributes][k][:_destroy] = value == '1' ? '0' : '1'
    end

    params.require(:property).permit(:number, :street, :address_line_2, :city, :county, :postcode,
                                     :number_of_bedrooms, :number_of_kitchens, :number_of_lounges,
                                     :number_of_dining_rooms, :number_of_toilets, :number_of_showers,
                                     :number_of_gardens, :number_of_studies, :number_of_utility_rooms,
                                     :number_of_studio_apartments, :other, :listing_type,
                                     :rental_type, :landlord_id, :home_rental_price, :room_rental_price, :pets,
                                     :style, :outside_space, :parking, :number_of_bathrooms, :ensuite, :list_on_website,
                                     :right_move, :on_the_market, :zoopla, :list_on_3rd_party_websites, :epc_rating,
                                     :council_tax_band, :furnished, :property_status_type,
                                     features_attributes: [:feature, :_destroy], image: [], property_type:[],
                                     compliance_documents_attributes: [:id, :document_file, :document_name, :document_expiry, :_destroy],
                                     attachments_attributes: [:id, :title, :attachment, :_destroy],
                                     property_list_student_attributes: [:id, :description, :list_price, :location,
                                                                        :college, :style, :pet_passport_allowed,
                                                                        :walk_to_city_campus, :front_photo, :deposit,
                                                                        :let_available_date, :minimum_term, :list_weekly,
                                                                        :list_monthly,
                                                                        :additional_features_1, :additional_features_2,
                                                                        :additional_features_3, :additional_features_4,
                                                                        :additional_features_5, :additional_features_6,
                                                                        :_destroy],
                                     property_list_graduate_attributes: [:id, :description, :list_price,
                                                                         :location, :student_allowed, :furnished,
                                                                         :council_tax_band, :front_photo, :deposit,
                                                                         :let_available_date, :minimum_term,
                                                                         :list_weekly, :list_monthly,
                                                                         :additional_features_1, :additional_features_2,
                                                                         :additional_features_3, :additional_features_4,
                                                                         :additional_features_5, :additional_features_6,
                                                                         :bus_route, :_destroy],
                                     property_list_professional_attributes: [:id, :description, :list_price, :location,
                                                                             :furnished, :council_tax_included,
                                                                             :council_tax_band, :bus_route, :front_photo,
                                                                             :deposit, :let_available_date, :minimum_term,
                                                                             :list_weekly, :list_monthly,
                                                                             :additional_features_1, :additional_features_2,
                                                                             :additional_features_3, :additional_features_4,
                                                                             :additional_features_5, :additional_features_6,
                                                                             :_destroy],
                                     property_list_family_attributes: [:id, :description, :list_price, :location,
                                                                       :school, :nearest_park_and_play_area,
                                                                       :area_family_location, :furnished,
                                                                       :council_tax_band, :front_photo, :deposit,
                                                                       :let_available_date, :minimum_term,
                                                                       :list_weekly, :list_monthly,
                                                                       :additional_features_1, :additional_features_2,
                                                                       :additional_features_3, :additional_features_4,
                                                                       :additional_features_5, :additional_features_6,
                                                                       :_destroy],
                                     property_listing_locations_attributes: [:id, :listing_type, :year, :user_id, :_destroy],
                                     property_utilities_attributes: [:id, :utility_name, :included, :landlord_contribution, :frequency, :_destroy]
                                    )
  end

  def tenancy_params
    params.require(:tenancy).permit(
      :first_name, :surname, :email, :mobile, :tenancy_start, :tenancy_end, :is_guarantor_available,
      :tenant_type, :deposit_term, :weekly_price, :monthly_price,  :advanced_rent_payment_amount, :number_of_weeks,
      :year, :deposit_guarantor_amount, :deposit_date, :number_of_months, :rent_due_date, :rent_payment_option,
      :total_tenancy_value, :number_of_payments, :payment_amount, :secondary_contact_first_name,
      :secondary_contact_last_name, :secondary_contact_phone_number, :secondary_contact_email, :tenancy_agreement_signature,
      :rent_installment_term, :initial_payment, :initial_payment_date, :tenancy_is ,term_due_dates: {},
      additional_tenants_attributes: [:first_name, :surname, :phone_number, :email])
  end

  def properties_filter(selected_properties, properties)
    data = []
    properties.each do |property|
      checked = (selected_properties.include? property.id.to_s) ? 'checked' : false;
      sel_class = checked==true ? 'plus' : 'minus'
      property_name = property.property_name
      property_id = property.id
      bathroom = (property.number_of_bathrooms.to_i>0) ? '<i class="fa fa-bath" aria-hidden="true"></i>' : ''
      avilability_ck = check_property_availability(property)
      price = property_rate(property)
      new_div = '<tr id="row-'+property_id.to_s+'"><td class="checkbox"><input type="checkbox" name="property_id[]" id="property_id_" class="properties_check'+' '+sel_class+'" data-property-id='+property_id.to_s+' value='+property_id.to_s+' '+checked.to_s+'><label for="a" class="css-label"><span class="fa fa-plus"></span><span class="fa fa-minus"></span</label></td><td class="property">'+property_name+'</td><td class="price">'+price+'</td><td class="ensuite">'+bathroom+'</td><td>'+avilability_ck.to_s+'</td></tr>'
      data << new_div.to_s
    end
    data << ['<tr><td class="property" colspan="4">No Properties available!</td></tr>'] if data.blank?
    return data
  end

  def manage_tanancy_end_date
    if @tenancy.nil? || (@tenancy.present? && !@tenancy.signed_tenancy_agreement?)
      if params[:tenancy]['tenancy_start(3i)']
        end_date = Date.parse("#{params[:tenancy]['tenancy_start(3i)']}-#{params[:tenancy]["tenancy_start(2i)"]}-#{params[:tenancy]["tenancy_start(1i)"]}")
      else
        end_date = Date.today
      end
      params[:tenancy][:tenancy_end] = params[:tenancy][:number_of_weeks] ? end_date + params[:tenancy][:number_of_weeks].to_i.weeks : end_date + params[:tenancy][:number_of_months].to_i.months
    end
  end

  def common_search_properties
    @properties = Property.includes(:events, rooms: :tenancies)
    @event = Event.find_by(id: params[:event_id])
    @event_property_ids = params[:selected_properties] ? params[:selected_properties].reject(&:empty?).map(&:to_i) : []
    @year = params[:year].present? ? params[:year] : @current_year
    if(params['ten_plus']=='yes')
      @properties = @properties.where('number_of_bedrooms >= ? or number_of_bedrooms != null ', '10')
    elsif !params["selected_rooms"].blank?
      @properties = @properties.where(number_of_bedrooms: params["selected_rooms"])
    end
    @year_id = @year.to_s.gsub('/', '-')
    tenancy_rooms = Tenancy.where(year: @year, booking_status: 2).pluck(:room_id)
    without_tenancy_properties = @properties.where(tenancies: { room_id: nil } )
    with_tenancy_properties = @properties.where.not(rooms: {id: tenancy_rooms})
    @properties = without_tenancy_properties.or(with_tenancy_properties)
    @search = params[:search].present? ? params[:search] : ''
    @properties = @properties.where('LOWER(properties.number) LIKE ? OR LOWER(properties.street) LIKE ? OR LOWER(properties.postcode) LIKE ? ', "%#{@search}%", "%#{@search}%", "%#{@search}%" ) if @search.present?
    @properties = @properties.order('properties.street, properties.id')
  end

  def create_compliance_documents(ids)
    generic_documents
    if ids && ids.count > 0
      generic_documents = GenericDocument.where(id: params[:ids])
      generic_documents.each do |generic_document|
        compliance_document = @property.compliance_documents.find_or_initialize_by(document_name: generic_document.document_name)
        compliance_document.document_expiry = generic_document.document_expiry
        compliance_document.document_file = generic_document.document_file
        compliance_document.generic_document_id = generic_document.id
        compliance_document.save
      end
      ids = ids.reject(&:empty?).map(&:to_i)
      doc_ids = @property_generic_document_ids - ids
      @property.compliance_documents.where(generic_document_id: doc_ids).delete_all
    end
  end

  def generic_documents
    @generic_documents = GenericDocument.select('DISTINCT(document_name), id')
    ids = @generic_documents.ids
    property_compliance_ids = []
    property_compliance_ids =  @property.compliance_documents.where(generic_document_id: ids).pluck(:generic_document_id) if @property.present?
    @property_generic_document_ids = property_compliance_ids
  end

  def admin_variable
    @admin_variable = AdminVariable.first
  end
end

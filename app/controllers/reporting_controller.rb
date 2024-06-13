class ReportingController < ApplicationController
  include Pagy::Backend

  def index
  end

  def combined_landlord_report
    #Property.generate_monthly_landlord_reports(regenerate: true)
    Property.combined_monthly_landlord_reports.save "combined.pdf"
  end

  def compliance_documents
    current_business_year
    @document = params.present? ? params.keys[0] : 'all'
    @compliance_documents = ComplianceDocument.includes(:property).all.order(:document_expiry)
    @expired_compliance_documents = @compliance_documents.where('DATE(document_expiry) < ?', Time.now)
    @next_month_expired_compliance_documents = @compliance_documents.where('extract(month from document_expiry) = ? AND extract(year from document_expiry) = ?', (Time.now + 1.month).strftime('%m'), (Time.now + 1.month).strftime('%Y'))
    @next_three_months_expired_compliance_documents = @compliance_documents.where('extract(month from document_expiry) BETWEEN ? AND ?', (Time.now).strftime('%m'), (Time.now + 3.month).strftime('%m')).where('extract(year from document_expiry) BETWEEN ? AND ?', (Time.now).strftime('%Y'), (Time.now + 3.month).strftime('%Y'))
    @missing_document_properties = Property.all.sorted_by('street_asc')
    missing_document_property_hash = @compliance_documents.where.not(property_id: nil).select(:document_name, :property_id).group_by(&:property_id)
    @missing_document_property_hash = {}
    missing_document_property_hash.each do |id, docs|
      docs.each do |doc|
        @missing_document_property_hash[id] ||= []
        @missing_document_property_hash[id] << doc.document_name
      end
    end
  end

  def list_of_people_in_arrears
    current_business_year
    @tenancies_in_arrears = Tenancy.in_arrears.where(
      tenancy_payment_items: {
        due_date: Date.parse("01-09-20#{@year.split('/')[0]}")..Date.parse("31-08-20#{@year.split('/')[1]}")
      }
    )
    # @tenancies_in_arrears = @tenancies_in_arrears.where(booking_status: 'complete')
      @filterrific = initialize_filterrific(
      @tenancies_in_arrears,
      params[:filterrific],
      select_options: {
        sorted_by: @tenancies_in_arrears.options_for_sorted_by_arrears_report
      },
      persistence_id: "arrears_report",
      default_filter_params: {},
      sanitize_params: true,
    ) || return
    @tenancies_in_arrears = @filterrific.find
    @total_list_of_tenancies_in_arrears = @tenancies_in_arrears.count(:id).count
    @order = params[:filterrific] && params[:filterrific][:sorted_by] ? params[:filterrific][:sorted_by] : 'surname_asc'
    respond_to do |format|
      format.html
      format.js
    end

    rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  def property_listings
    # @properties = Property.all
    # @properties = Property.joins(:property_listing_locations)
    @properties = Property.where('list_on_3rd_party_websites = true')
    # @properties = @properties.joins(:property_listing_locations).where('listing_type = website')

    # @landlords = Landlord.joins(properties: [rooms: [tenancies: :tenancy_payment_items]])
    # @landlords = @landlords.where(tenancies: { booking_status: 'complete' })

    # rooms = Room.joins(:tenancies, [property: :landlord]).where('tenancies.tenancy_end <= ?', @end_date)
  end

  def viewings
    @filterrific = initialize_filterrific(
        viewings_params,
        params[:filterrific],
        select_options: {
            sorted_by: Event.options_for_sorted_by
        },
        persistence_id: "events_key",
        default_filter_params: {},
        sanitize_params: true,
        ) || return
    @pagy, @events = pagy(@filterrific.find, items: 10)

    respond_to do |format|
      format.html
      format.js
    end

    rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  def tenancies
    tenancies = Tenancy.where("tenancy_end BETWEEN ? AND ?", Time.now, Time.now + 30.days)
    if params[:expiry_time].present?
    end
    @filterrific = initialize_filterrific(
      tenancies,
      params[:filterrific],
      select_options: {
        sorted_by: Tenancy.options_for_sorted_by
      },
      persistence_id: "tenancies_key",
      default_filter_params: {},
      sanitize_params: true,
      ) || return
    @pagy, @tenancies = pagy(@filterrific.find, items: 10)

    respond_to do |format|
      format.html
      format.js
    end

    rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  ## print arrears report
  def print_arrears
    current_business_year
    @order = params[:order]
    @ids = params[:ids] ? params[:ids].to_s.split(" ") : []
    arrears_pdf = PeopleArrearPdf.new(@ids, @year, @order).render
    pdf_file_name = "#{Date.today.strftime('%d_%b_%y_%h_%m')}.pdf"
    send_data(arrears_pdf, filename: pdf_file_name, type: "application/pdf", disposition: "inline")
  end

  ## send arrears report
  def send_arrear_report
    current_business_year
    mail = params[:send] == 'james' ? "james@cityletsplymouth.co.uk" : "accounts@cityletsplymouth.co.uk"
    @ids = params[:ids] ? params[:ids].to_s.split(" ") : []
    @order = params[:order]
    LandlordMailer.send_arrear_mail(mail, @ids, @year, @order).deliver_now
  end

  ## monthly payment report
  def monthly_payment_report
    current_business_year
    year = Date.today.month < 9 ? @year.last(2) : @year.first(2)
    @start_date = Date.parse("01-#{Date.today.month}-20#{year}")
    @end_date = Date.parse("#{Date.today.end_of_month.day}-#{Date.today.month}-20#{year}")
    @landlords = Landlord.order(:contact_name)
    rooms = Room.joins(:tenancies, [property: :landlord]).where('tenancies.tenancy_end <= ?', @end_date)
    @rooms = rooms.group('landlords.id').sum('rooms.list_price')
    @completed_rooms = rooms.where(availability: false).group('landlords.id').sum('rooms.list_price')
    @property_expenses = Property.joins(:property_expenses).where(
      'property_expenses.expense_date between ? and ?', @start_date, @end_date
    ).group(:landlord_id).sum('property_expenses.amount')
  end

  ## Print monthly payment report
  def print_monthly_payment_report
    current_business_year
    year = Date.today.month < 9 ? @year.last(2) : @year.first(2)
    @start_date = Date.parse("01-#{Date.today.month}-20#{year}")
    @end_date = Date.parse("#{Date.today.end_of_month.day}-#{Date.today.month}-20#{year}")
    monthly_payment = MonthlyPaymentPdf.new(@start_date, @end_date).render
    pdf_file_name = "monthly_payment_#{Date.today.strftime('%d_%b_%y_%h_%m')}.pdf"
    send_data(monthly_payment, filename: pdf_file_name, type: "application/pdf", disposition: "inline")
  end

  ## Generate monthly payment report
  def generate_monthly_payment_report
    begin
      start_date = params[:start_date]
      end_date = params[:end_date]
      monthly_payment = MonthlyPaymentPdf.new(Date.parse(start_date), Date.parse(end_date)).render
      pdf_file_name = "monthly_payment_#{Date.today.strftime('%d_%b_%y_%h_%m')}.pdf"
      send_data(monthly_payment, filename: pdf_file_name, type: "application/pdf", disposition: "inline")
    rescue Exception => e
      errors = e.message
      redirect_to monthly_payment_report_path, alert: errors
    end
  end

  ## print the compliace report
  def print_compliance_report
    @report_for = params[:report_for]
    compliance_document = ComplianceDocumentPdf.new(@report_for).render
    pdf_file_name = "compliance_document_#{Date.today.strftime('%d_%b_%y_%h_%m')}.pdf"
    send_data(compliance_document, filename: pdf_file_name, type: "application/pdf", disposition: "inline")
  end

  ## Annual commission report
  def annual_commission_report
    current_report_year
    @annual_types = Landlord.partnership_formats.keys - ['Owned']
    landlords = Landlord.eager_load(properties: [rooms: [tenancies: :tenancy_payment_items]])
    landlords = landlords.where(tenancies: { booking_status: 'complete' })
    @annual_data = {}
    date = Date.parse("01/08/#{Date.today.year.to_s[0..1]}#{@year[0..1]}")
    @total_avr = 0.0
    @total_month = {}
    @total_partner = {}
    @annual_types.each do |annual_type|
      @total_partner[annual_type] = 0 unless @total_partner[annual_type]
      @annual_data[annual_type] = {}
      @annual_data[annual_type]["AvR"] = 0.0 unless @annual_data[annual_type]["AvR"]
      @get_landlords = landlords.where(partnership_format: annual_type)
      complete_landlord_income = @get_landlords.where(
        'tenancy_payment_items.due_date between ? and ?',
        Date.parse("01/09/#{Date.today.year.to_s[0..1]}#{@year[0..1]}"),
        Date.parse("31/08/#{Date.today.year.to_s[0..1]}#{@year[3..4]}")
      )
      annual_rent = complete_landlord_income.where('tenancy_payment_items.item = ?', 'Rent').group(
      ['landlords.id', 'tenancy_payment_items.due_date']).sum('tenancy_payment_items.amount_due')
      annual_adv = complete_landlord_income.where('tenancy_payment_items.item = ?', 'AvR').group(
      'landlords.id').sum('tenancy_payment_items.amount_due')
      annual_rent = annual_rent.each_with_object({}) { |(k,v),h| h["#{k[0]}, #{k[1].strftime('%b, %Y')}"] = (h["#{k[0]}, #{k[1].strftime('%b, %Y')}"] || 0) + v }


      @get_landlords.each do |landlord|
        total_avr = 0
        (1..12).each do |i|

          current_date = (date + i.month)
          price = (annual_rent && annual_rent["#{landlord.id}, #{current_date.strftime('%b, %Y')}"]) ? annual_rent["#{landlord.id}, #{current_date.strftime('%b, %Y')}"] : 0.0
          @annual_data[annual_type][current_date] = 0 unless @annual_data[annual_type][current_date]
          @total_month[current_date] = 0.0 unless @total_month[current_date]
          total_month_partner = 0

          if annual_type == 'Listing Partner' || annual_type == 'Tenancy Partner'
            total_month_partner = landlord.fee.to_f if price > 0.0
          elsif annual_type == 'Booking Partner'
            total_month_partner =   landlord.fee.to_f if price > 0.0
          else
            total_month_partner = (landlord.rate ? ((price * landlord.rate.to_f) / 100).round(2) : 0.0)
          end
          @annual_data[annual_type][current_date] += total_month_partner
          @total_month[current_date] += total_month_partner
        end
        avr = annual_adv && annual_adv[landlord.id] ?  annual_adv[landlord.id] : 0.0
        total_avr = !["Listing Partner", 'Booking Partner', "Listing Partner"].include?(annual_type) ? (landlord.rate ? ((avr * landlord.rate.to_f) / 100).round(2) : 0.0) : 0.0
        @annual_data[annual_type]["AvR"] += total_avr
        @total_avr += total_avr
      end
      @total_partner[annual_type] = @annual_data[annual_type].values.sum
      @total_inc_vat = (@total_partner[annual_type] * 0.2)
    end
  end

  ## print annual report
  def print_annual_commission_report
    current_report_year
    annual_income_pdf = AnnualIncomeReportPdf.new(@year).render
    pdf_file_name = "annual_commission_#{Date.today.strftime('%d_%b_%y_%h_%m')}.pdf"
    send_data(annual_income_pdf, filename: pdf_file_name, type: "application/pdf", disposition: "inline")
  end

  ## annual rent report
  def annual_rent_report
    current_report_year
    @annual_types = ['Complete Partner', 'Support Partner', 'Owned']
    get_annual_report_data
  end

  ## print annual rent report
  def print_annual_rent_report
    current_report_year
    annual_rent_pdf = AnnualRentReportPdf.new(@year).render
    pdf_file_name = "annual_rent_#{Date.today.strftime('%d_%b_%y_%h_%m')}.pdf"
    send_data(annual_rent_pdf, filename: pdf_file_name, type: "application/pdf", disposition: "inline")
  end

  ## sales analysis report
  def sales_analysis_report
    current_business_year
    @all_rooms = Room.includes(:property, :tenancies).joins(:property)
    tenancy_complete_rooms = Tenancy.where(booking_status: 2, year: @year).pluck(:room_id)
    tenancy_rooms = @all_rooms.where.not(id: tenancy_complete_rooms, tenancies: {room_id: nil})
    available_rooms = @all_rooms.where(tenancies: {room_id: nil})
    @rooms = available_rooms.or(tenancy_rooms)
    @rooms = @rooms.order('properties.street, properties.id, rooms.number')
    @available_rooms = @rooms
    @booked_rooms = @rooms.joins(:tenancies).where(
      'tenancies.booking_status in (?) and tenancies.year = ?', [1], @year
    )
    @non_complete_rooms = @available_rooms.count + @booked_rooms.count
    @total_complete_rooms = tenancy_complete_rooms.count
    if @total_booked_rooms == 0
      @percentage = 0
    else
      @percentage = (@total_complete_rooms * 100) / @rooms.count
    end
  end

  ## print sales anaalysis report
  def print_sales_analysis_report
    current_business_year
    sales_analysis_pdf = SalesAnalysisReportPdf.new(@year).render
    pdf_file_name = "sales_analysis_of_#{Date.today.strftime('%d_%b_%y_%h_%m')}.pdf"
    send_data(sales_analysis_pdf, filename: pdf_file_name, type: "application/pdf", disposition: "inline")
  end

  ## available rooms report
  def available_room
    current_business_year
    @all_rooms = Room.includes(:property, :tenancies).joins(:property)
    tenancy_complete_rooms = Tenancy.where(booking_status: 2, year: @year).pluck(:room_id)
    tenancy_rooms = @all_rooms.where.not(id: tenancy_complete_rooms, tenancies: {room_id: nil})
    available_rooms = @all_rooms.where(tenancies: {room_id: nil})
    @rooms = available_rooms.or(tenancy_rooms)
    @rooms = @rooms.order('properties.street, properties.id, rooms.number')
    @available_rooms = @rooms
  end

  ## print available rooms report
  def print_available_room
    current_business_year
    available_rooms_pdf = AvailableRoomReportPdf.new(@year).render
    pdf_file_name = "available_rooms_of_#{Date.today.strftime('%d_%b_%y_%h_%m')}.pdf"
    send_data(available_rooms_pdf, filename: pdf_file_name, type: "application/pdf", disposition: "inline")
  end

  private

    def viewings_params
      if params[:timing] == 'today_events'
        @events = Event.where("DATE(events.start) = ? OR DATE(events.end) = ?", Date.today.strftime, Date.today.strftime )
      elsif params[:timing] == 'week_events'
        @events = Event.where("DATE(events.start) >= ? AND DATE(events.end) <= ?", Date.today.beginning_of_week.strftime, Date.today.end_of_week.strftime)
      else
        @events = Event.where("DATE(events.start) >= ? AND DATE(events.end) <= ?", Date.today.beginning_of_month.strftime, Date.today.end_of_month.strftime)
      end
      return @events
    end

    def get_annual_report_data
      @annual_data = {}
      @landlords = Landlord.joins(properties: [rooms: [tenancies: :tenancy_payment_items]])
      @landlords = @landlords.where(tenancies: { booking_status: 'complete' })
      @sum = 0
      @total_avr = 0
      @annual_types.each do |format_type|
        complete_landlord_income = @landlords.where(partnership_format: format_type).where(
          'tenancy_payment_items.due_date between ? and ?',
          Date.parse("01/09/#{Date.today.year.to_s[0..1]}#{@year[0..1]}"),
          Date.parse("31/08/#{Date.today.year.to_s[0..1]}#{@year[3..4]}")
        )
        @annual_data[format_type] = {}
        @annual_data[format_type]['income'] = complete_landlord_income.where('tenancy_payment_items.item = ?', 'Rent').group(
        'tenancy_payment_items.due_date').sum('tenancy_payment_items.amount_due')
        @annual_data[format_type]["AvR"] = complete_landlord_income.where('tenancy_payment_items.item = ?', 'AvR').sum('tenancy_payment_items.amount_due')
        @annual_data[format_type]['income'] = @annual_data[format_type]['income'].each_with_object({}) { |(k,v),h| h[k.strftime('%b, %Y')] = (h[k.strftime('%b, %Y')] || 0) + v }

        @total_avr += @annual_data[format_type]["AvR"]
        @annual_data[format_type]['total_income'] = @annual_data[format_type]["AvR"] + @annual_data[format_type]['income'].values.sum
        @sum += @annual_data[format_type]['total_income']
        @sum_inc_vat = (@sum * 0.2)
      end
    end

    def current_business_year
      @year = params[:year] ? params[:year] : @current_year
    end

    def current_report_year
      date = params[:year] ? Date.parse("01/09/#{Date.today.year.to_s[0..1]}#{params[:year][0..1]}") : Date.today
      month = date.month
      year = date.strftime('%y').to_i
      @year = month < 9 ? "#{year - 1}/#{year}" : "#{year}/#{year + 1}"
    end
end

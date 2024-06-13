require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 529
class LandlordBookingReportPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(landlord, year)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @year = year
    @landlord = landlord
    @properties = @landlord.properties
    @properties = @properties.includes(tenancies: :room).eager_load(tenancies: :room).where('tenancies.year = ? and archived = ?', @year, false).uniq unless @year == 'all'
    @let_tenancies = @landlord.tenancies.where(booking_status: [1, 2]).where(year: '23/24')
    @landlord_rooms = @landlord.rooms
    @total_rooms = @landlord_rooms.count.to_i
    @total_let_tenancies = @let_tenancies.count.to_i
    @property_let = @total_rooms > 0 ? (@total_let_tenancies * 100 / @total_rooms) : 0
    @income = TenancyPaymentItem.where(tenancy_id: @let_tenancies.ids).pluck(:amount_due).sum(&:to_f)

    @let_next_year_tenancies = @landlord.tenancies.where(booking_status: [1, 2]).where(year: '24/25')
    # @landlord_rooms = @landlord.rooms
    # @total_rooms = @landlord_rooms.count.to_i
    @total_let_tenancies_next_year = @let_next_year_tenancies.count.to_i
    @property_let_next_year = @total_rooms > 0 ? (@total_let_tenancies_next_year * 100 / @total_rooms) : 0
    @income_next_year = TenancyPaymentItem.where(tenancy_id: @let_next_year_tenancies.ids).pluck(:amount_due).sum(&:to_f)

    font "Quicksand"
    upper_header
    landlord_booking_report
  end

  def upper_header
    logo_path =  "#{Rails.root}/app/assets/images/city-lets-trimmed.png"
    image logo_path, width: 200, height: 80, at: [165, y-40]
    address
    move_down 10
    line_width 2
    stroke_horizontal_line(0, bounds.width)
    move_down 10
  end

  def address
    move_down 100
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end

  def landlord_booking_report
    unless @landlord.blank?
      landlord_booking
    end
  end

  def landlord_booking
    @lanlord_statement ||= booking_report
  end

  def booking_report
    text "<b>#{@landlord.contact_name} Booking Report on #{Date.today.to_s(:long)} </b>", size: 16, align: :center, inline_format: true
    move_down 10
    t = make_table([['Percentage Let', 'Amount', 'Income Contracted'], ["#{@property_let}%", "#{@total_let_tenancies}/#{@landlord_rooms.count}", "£#{number_with_delimiter(sprintf("%.2f",@income), delimiter: ',')}"]], cell_style: { border_width: 1, align: :center }, column_widths: 177) do
      style row(0), size: 12, background_color: "6c757d", text_color: "ffffff", font_style: :bold
    end
    t.draw
    move_down 20
    t = make_table(get_landlord_booking, cell_style: { border_width: 1, border_color: '6c757d', align: :center }, column_widths: 532/8 )  do
      style row(0), size: 10, background_color: "28a745", font_style: :bold
    end
    t.draw
    move_down 20

    start_new_page
    text "<b>Year: 24/25</b>", size: 24, align: :center, inline_format: true
    move_down 20
    t = make_table([['Percentage Let', 'Amount', 'Income Contracted'], ["#{@property_let_next_year}%", "#{@total_let_tenancies_next_year}/#{@landlord_rooms.count}", "£#{number_with_delimiter(sprintf("%.2f",@income_next_year), delimiter: ',')}"]], cell_style: { border_width: 1, align: :center }, column_widths: 177) do
      style row(0), size: 12, background_color: "6c757d", text_color: "ffffff", font_style: :bold
    end
    t.draw
    move_down 20

    t = make_table(get_landlord_booking_next_year, cell_style: { border_width: 1, border_color: '6c757d', align: :center }, column_widths: 532/8 )  do
      style row(0), size: 10, background_color: '28a745', border_color: '000000', font_style: :bold
    end
    t.draw
    move_down 20
  end

  def monthly_payment_price(tenant)
    if tenant.deposit_term == 'termly'
      rate = tenant.monthly_price
    else
      rate = tenant.payment_amount
    end
    return rate
  end

  def get_landlord_booking
    table_data = [["Property", "Room", "Monthly Rent", "Tenancy", "Guarantor", "Start", 'End', "Signed Tenancy"]]
    if @properties.count > 0
      @properties.each do |property|
        rooms = @year != "all" ? property.rooms.includes(tenancies: :guarantor).eager_load(:tenancies).where("tenancies.year = ?", @year).order(:id).uniq : property.rooms.order(:id).uniq
        if rooms.count > 0
          rooms.each_with_index do |room, i|
            tenancies = @year != '23/24' ? room.tenancies.not_archived.where(year: '23/24').uniq : room.tenancies.not_archived.uniq
            if tenancies.count > 0
              tenancies.each_with_index do |tenancy, j|
                table_data << [
                  (property.property_name if (i == 0 && j == 0)),
                  (room.number if j == 0),
                  # ("£#{number_with_delimiter(sprintf("%.2f",tenancy.payment_amount.to_f), delimiter: ',')}"), "Yes",
                  ("£#{number_with_delimiter(sprintf("%.2f",monthly_payment_price(tenancy).to_f), delimiter: ',')}"), "Yes",
                  # (room.availability ? "Available" : "£#{number_with_delimiter(sprintf("%.2f",tenancy.payment_amount.to_f), delimiter: ',')}"), "Yes",
                  # (room.availability ? "£#{number_with_delimiter(sprintf("%.2f",room.list_price.to_f), delimiter: ',')}" : "£#{number_with_delimiter(sprintf("%.2f",room.list_price.to_f), delimiter: ',')}"), "Yes",
                  (tenancy.guarantor.present? ? "Yes" : "No"),
                  tenancy.tenancy_start.try(:strftime, '%d/%m/%Y'),
                  tenancy.tenancy_end.try(:strftime, '%d/%m/%Y'),
                  # (tenancy.year),
                  (tenancy.signed_tenancy_agreement ? 'Yes' : 'No')
                ]
              end
            else
              table_data << [(property.property_name if i == 0), room.number, '', '', '', '', '', '']
            end
          end
        else
          table_data << [property.property_name, '', '', '', '', '', '', '']
        end
      end
    else
      table_data << [{content: "Properties are not Available", colspan: 8, align: :left, font_style: :bold, text_color: "dc3545"}]
    end
    table_data
  end

  def get_landlord_booking_next_year
    table_data = [["Property", "Room", "Monthly Rent", "Tenancy", "Guarantor", "Start", 'End', "Signed Tenancy"]]
    if @properties.count > 0
      @properties.each do |property|
        rooms = @year != "all" ? property.rooms.includes(tenancies: :guarantor).eager_load(:tenancies).where("tenancies.year = ?", @year).order(:id).uniq : property.rooms.order(:id).uniq
        if rooms.count > 0
          rooms.each_with_index do |room, i|
            tenancies = @year != '24/25' ? room.tenancies.not_archived.where(year: '24/25').uniq : room.tenancies.not_archived.uniq
            if tenancies.count > 0
              tenancies.each_with_index do |tenancy, j|
                table_data << [
                  (property.property_name if (i == 0 && j == 0)),
                  (room.number if j == 0),
                  ("£#{number_with_delimiter(sprintf("%.2f",tenancy.payment_amount.to_f), delimiter: ',')}"), "Yes",
                  # (room.availability ? "Available" : "£#{number_with_delimiter(sprintf("%.2f",room.list_price.to_f), delimiter: ',')}"), "Yes",
                  (tenancy.guarantor.present? ? "Yes" : "No"),
                  tenancy.tenancy_start.try(:strftime, '%d/%m/%Y'),
                  tenancy.tenancy_end.try(:strftime, '%d/%m/%Y'),
                  # (tenancy.year),
                  (tenancy.signed_tenancy_agreement ? 'Yes' : 'No')
                ]
              end
            else
              table_data << [(property.property_name if i == 0), room.number, '', '', '', '', '', '']
            end
          end
        else
          table_data << [property.property_name, '', '', '', '', '', '', '']
        end
      end
    else
      table_data << [{content: "Properties are not Available", colspan: 8, align: :left, font_style: :bold, text_color: "dc3545"}]
    end
    table_data
  end

  def document_badge(url)
    table_icon "<link href='#{url}' target='_blank'><icon color='28a745'>fas-file-pdf</icon></link>", inline_format: true
  end

  def get_documents(tenancy)
    tenancy.tenancy_documents.where(document_name: ['booking_form', 'signed_tenancy_agreement', 'tenancy_compliance']).uniq.each do |doc|
      if doc.document_file && doc.document_file.url.present?
        "#{document_badge(doc.document_file.url)}".html_safe
      end
    end
  end
end
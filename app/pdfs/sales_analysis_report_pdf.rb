require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 529
class SalesAnalysisReportPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(year)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @year = year
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
    @total_available_rooms = @available_rooms.count
    @total_booked_rooms = @booked_rooms.count
    @percentage = (@total_booked_rooms * 100) / @rooms.count
    font "Quicksand"
    upper_header
    sales_analysis_report
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

  def sales_analysis_report
    unless @rooms.blank?
      sales_analysis
    end
  end

  def sales_analysis
    @sales_analysis ||= sales_report
  end

  def sales_report
    text "<b>Sales Analysis Report</b>", inline_format: true, size: 16, align: :center
    move_down 20
    t = make_table([["Booked Rooms", "Available Rooms", "Percentage"], ["#{@total_booked_rooms}", "#{@total_available_rooms}", "#{@percentage.round(2)}%"]], cell_style: { border_width: 1, align: :center }, column_widths: 175) do
      style row(0), size: 14, background_color: "6c757d", text_color: "ffffff"
    end
    t.draw
    move_down 20
    text "Available Rooms", size: 16
    move_down 20
    t = make_table(get_available_rooms, cell_style: { border_width: 1}, column_widths: 175) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
    move_down 20
    text "Booked Rooms", size: 16
    move_down 20
    t = make_table(get_booked_rooms, cell_style: { border_width: 1}, column_widths: 88) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
    move_down 20
  end

  def get_booked_rooms
    table_data = [["Address", "Room", "Rent", "Start", "End", "Contact Value"]]
    if @booked_rooms.count > 0
      @booked_rooms.each do |room|
        room.tenancies.not_archived.where(booking_status: ['booking', 'complete']).each_with_index do |tenancy, i|
          table_data << [
            (room&.property&.property_name if i == 0),
            (room.number if i == 0), ("£#{number_with_delimiter(sprintf("%.2f",room.list_price.to_f), delimiter: ',')}"if i == 0),
            tenancy.tenancy_start.strftime('%d/%m/%Y'), tenancy.tenancy_end.strftime('%d/%m/%Y'),
            "£#{tenancy.total_tenancy_value}"
          ]
        end
      end
    else
      table_data << [{content: "No Booked Rooms", colspan: 6, align: :left, font_style: :bold, text_color: "dc3545"}]
    end
    table_data
  end

  def get_available_rooms
    table_data = [["Address", "Room", "Rent"]]
    if @available_rooms.count > 0
      @available_rooms.each do |room|
        table_data << [room&.property&.property_name, room.number, "£#{number_with_delimiter(sprintf("%.2f",room.list_price.to_f), delimiter: ',')}"]
      end
    else
      table_data << [{content: "No Available Rooms", colspan: 3, align: :left, font_style: :bold, font_color: "dc3545"}]
    end
    table_data
  end

  def address
    move_down 100
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end
end

require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 529
class AvailableRoomReportPdf < Prawn::Document
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
    font "Quicksand"
    upper_header
    availability_report
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

  def availability_report
    unless @rooms.blank?
      availability_rooms
    end
  end

  def availability_rooms
    @availability_rooms ||= availability_room_reports
  end

  def availability_room_reports
    text "<b>Availability Report</b>", size: 16, align: :center, inline_format: true
    move_down 20
    text "Key Figures", size: 16
    move_down 10
    t = make_table([["Quantity Available"], ["#{@available_rooms.count}"]], cell_style: { border_width: 1, align: :center }, column_widths: 175) do
      style row(0), size: 14, background_color: "6c757d", text_color: "ffffff"
    end
    t.draw
    move_down 20
    text "Available Rooms", size: 16
    move_down 10
    t = make_table(get_available_rooms, cell_style: { border_width: 1}, column_widths: 170) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
    move_down 20
  end

  def get_available_rooms
    table_data = [["Address", "Room", "Rent"]]
    if @available_rooms.count > 0
      @available_rooms.each do |room|
        table_data << [room&.property&.property_name, room.number, "£#{number_with_delimiter(sprintf("%.2f",room.list_price.to_f), delimiter: ',')}"]
      end
    else
      table_data << [{content: "Rooms are not available", colspan: 3, align: :left, font_style: :bold, text_color: "dc3545"}]
    end
    table_data
  end

  def address
    move_down 100
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end

end

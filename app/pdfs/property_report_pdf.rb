require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 529
class PropertyReportPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @properties = Property.includes(:landlord, :property_expenses, rooms: :tenancies)
    @let_tenancies = Tenancy.where("tenancy_start between ? and ? or tenancy_end between ? and ? or tenancy_end > ? and booking_status in (?) and tenancy_start < ?" , Date.today.prev_month.at_beginning_of_month,Date.today.prev_month.at_end_of_month, Date.today.prev_month.at_beginning_of_month,Date.today.prev_month.at_end_of_month, Date.today.prev_month.at_end_of_month, [1, 2], Date.today.at_beginning_of_month).count
    @total_rooms = Room.count
    @property_let = @let_tenancies * 100 / @total_rooms
    @arrears = TenancyPaymentItem.where(due_date: Date.today.prev_month.at_beginning_of_month..Date.today.prev_month.at_end_of_month)
    @total_arrears = @arrears.pluck(:arrears).sum(&:to_f)
    @arrears_count = @arrears.count
    font "Quicksand"
    upper_header
    property_reports
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

  def property_reports
    unless @properties.blank?
      statment_reports
    end
  end

  def statment_reports
    @statment_reports ||= property_statement_report
  end

  def property_statement_report
    text "<b>Period Ending of #{Date.today.prev_month.at_end_of_month.strftime('%d %B %Y')}</b>", align: :center, size: 16, inline_format: true
    move_down 10
    t = make_table([["Total Properties", "% Properties Let", "No. in Arrears", "Amount in Arrears" ], [@properties.count,   "#{@property_let}%", @arrears_count, number_with_delimiter(sprintf("%.2f",@total_arrears), delimiter: ',')]], cell_style: { border_width: 1, align: :center }, column_widths: 130) do
      style row(0), size: 14, background_color: "6c757d", text_color: "ffffff"
    end
    t.draw
    move_down 20
    line_width 2
    stroke_horizontal_line(0, bounds.width)
    move_down 20
    t = make_table(get_properties, cell_style: { border_width: 1}, column_widths: 85) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
    move_down 20
  end

  def get_properties
    table_data = [["Property", "Income", "Commision", "Arrears", "Expenses", "Total"]]
    @properties.each do |property|
      table_data << [{content: property.property_name, colspan: 6, align: :left, font_style: :bold, background_color: "bee5eb"}]
      property_expenses = property.property_expenses.where(expense_date: Date.today.prev_month.at_beginning_of_month..Date.today.prev_month.at_end_of_month).sum(&:amount)
      property.rooms.each do |room|
        room_income = @arrears.where(tenancy_id: room.tenancies.pluck(:id))
        total_income = room_income.sum(:amount_paid)
        total_arrears = room_income.pluck(:arrears).sum(&:to_f)
        commision = property.landlord ? (total_income * (property.landlord.rate.to_f/100)) : 0
        total_balance = total_income - commision - total_arrears - property_expenses
        table_data << [ "Room #{room.number}", "£#{number_with_delimiter(sprintf("%.2f",total_income), delimiter: ',')}", "£#{number_with_delimiter(sprintf("%.2f",commision), delimiter: ',')}", ("£#{number_with_delimiter(sprintf("%.2f",total_arrears), delimiter: ',')}" if total_arrears), "£#{number_with_delimiter(sprintf("%.2f",property_expenses), delimiter: ',')}", "£#{number_with_delimiter(sprintf("%.2f",total_balance), delimiter: ',')}"]
      end
    end
    table_data
  end

  def address
    move_down 100
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end
end

require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 1300
class MonthlyPaymentPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(start_date, end_date)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @start_date = start_date
    @end_date = end_date
    @landlords = Landlord.all.order(:contact_name)
    @property_expenses = Property.joins(:property_expenses).where(
      'property_expenses.expense_date between ? and ?', @start_date, @end_date
    ).group(:landlord_id).sum('property_expenses.amount')
    rooms = Room.joins(:tenancies, [property: :landlord]).where('tenancies.tenancy_end <= ?', @end_date)
    @rooms = rooms.group('landlords.id').sum('rooms.list_price')
    @completed_rooms = rooms.where(availability: false).group('landlords.id').sum('rooms.list_price')
    font "Quicksand"
    upper_header
    monthly_payment_report
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

  def monthly_payment_report
    unless @landlords.blank?
      monthly_payment_data
    end
  end

  def monthly_payment_data
    @monthly_payment_data ||= monthly_payment
  end

  def monthly_payment
    text "<b>Monthly Payment Report between #{@start_date.strftime('%d %B %Y')} and #{@end_date.strftime('%d %B %Y')}</b>", size: 16, align: :center, inline_format: true
    move_down 20
    t = make_table(get_monthly_payments, cell_style: { border_width: 1 }, column_widths: 175) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
    move_down 10
  end

  def get_monthly_payments
    table_data = [["Landlord", "Income Total", "Total Payment due"]]
    @landlords.each do |landlord|
      rent_price = @rooms[landlord.id] ? @rooms[landlord.id] : 0.0
      property_expense = @property_expenses[landlord.id] ? @property_expenses[landlord.id] : 0.0
      total_income = rent_price - property_expense
      if landlord.partnership_format == 'Listing Partner' || landlord.partnership_format == "Booking Partner"
        commission = total_income - landlord.fee.to_f
      elsif landlord.partnership_format == 'Booking Partner'
        total_income = (@completed_rooms[landlord.id] ? @completed_rooms[landlord.id] : 0.0) - property_expense
        commission = total_income - (landlord.fee.to_f)
      else
        commission = total_income - ((rent_price * landlord.rate.to_f )/100)
      end
      table_data << [landlord.landlord_name, number_with_delimiter(sprintf("%.2f",total_income), delimiter: ','), number_with_delimiter(sprintf("%.2f",commission ), delimiter: ',') ]
    end
    table_data
  end

  def address
    move_down 90
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end
end

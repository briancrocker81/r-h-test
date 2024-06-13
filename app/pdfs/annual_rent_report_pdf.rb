require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 1300
class AnnualRentReportPdf < Prawn::Document
  PAGE_MARGIN = [20, 20, 20, 20]
  # legal - 612.00 x 1008.00
  def initialize(year)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :landscape)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @year = year
    @annual_types = ['Complete Partner', 'Support Partner','Owned']
    @landlords = Landlord.joins(properties: [rooms: [tenancies: :tenancy_payment_items]])
    @landlords = @landlords.where(tenancies: { booking_status: 'complete' })
    @sum = 0
    @annual_data = {}
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
    end
    font "Quicksand"
    upper_header
    annual_rent_report
  end

  def upper_header
    logo_path =  "#{Rails.root}/app/assets/images/city-lets-trimmed.png"
    image logo_path, width: 270, height: 80, at: [350, y-20]
    address
    move_down 10
    line_width 2
    stroke_horizontal_line(0, bounds.width)
    move_down 10
  end

  def annual_rent_report
    unless @annual_data.blank?
      annual_rent_data
    end
  end

  def annual_rent_data
    @annual_rent_data ||= get_annual_rent
  end

  def get_annual_rent
    text "<b>Annual Rent Report for year - #{@year}</b>", size: 16, align: :center, inline_format: true
    move_down 10
    t = make_table([['Total Annual Rent'], ["£#{number_with_delimiter(sprintf("%.2f",@sum), delimiter: ',')}"]], cell_style: { border_width: 1, align: :center, font_style: :bold }, column_widths: 175, position: :center ) do
      style row(0), size: 14, background_color: "6c757d", text_color: "ffffff"
    end
    t.draw
    move_down 10
    annual_rent_records = get_rent_data
    width = 968/annual_rent_records[0].length
    t = make_table(annual_rent_records, cell_style: { border_width: 1 }, column_widths: width) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
      style row(-1), size: 12, font_style: :bold, background_color: "343a40", text_color: "ffffff", height: 30
      style column(-1), size: 12, font_style: :bold
      style column(0), size: 12, font_style: :bold
    end
    t.draw
    move_down 10
  end

  def get_rent_data
    date = Date.parse("01/08/#{Date.today.year.to_s[0..1]}#{@year[0..1]}")
    table_data = [["Type", "Advance Rate"]]
    total = {}
    @annual_data.each do |key, annual_rent|
      data = [key, "£#{number_with_delimiter(sprintf("%.2f",annual_rent["AvR"]), delimiter: ',')}"]
      (1..12).each do |i|
        total[(date + i.month).strftime("%b, %Y")] = 0 if total[(date + i.month).strftime("%b, %Y")].blank?
        if annual_rent['income'][(date + i.month).strftime("%b, %Y")]
          data << "£#{number_with_delimiter(sprintf("%.2f",annual_rent['income'][(date + i.month).strftime("%b, %Y")]), delimiter: ',')}"
          total[(date + i.month).strftime("%b, %Y")] += annual_rent['income'][(date + i.month).strftime("%b, %Y")]
        else
          data << "£#{0.0}"
        end
      end
      data << "£#{number_with_delimiter(sprintf("%.2f",annual_rent['total_income']), delimiter: ',')}"
      table_data << data
    end
    data = ['Total', "£#{number_with_delimiter(sprintf("%.2f",@total_avr), delimiter: ',')}"]
    (1..12).each do |i|
      table_data[0] << (date + i.month).strftime("%b")
      data << "£#{number_with_delimiter(sprintf("%.2f",total[(date + i.month).strftime("%b, %Y")]), delimiter: ',')}"
    end
    table_data[0] << 'Total'
    data <<  "£#{number_with_delimiter(sprintf("%.2f",@sum), delimiter: ',')}"
    table_data << data
    table_data
  end

  def address
    move_down 90
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end

end

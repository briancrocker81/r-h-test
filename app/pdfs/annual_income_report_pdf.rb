require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 1300
class AnnualIncomeReportPdf < Prawn::Document
  PAGE_MARGIN = [20, 20, 20, 20]
  # legal - 612.00 x 1008.00
  def initialize(year)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :landscape)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @year = year
    get_income
    font "Quicksand"
    upper_header
    annual_income_report
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

  def annual_income_report
    unless @annual_data.blank?
      annual_income_data
    end
  end

  def annual_income_data
    @annual_income_data ||= get_annual_income
  end

  def get_annual_income
    text "<b>Annual Income Commission for year - #{@year}</b>", size: 16, align: :center, inline_format: true
    move_down 10
    t = make_table([['Total Annual Income'], ["£#{number_with_delimiter(sprintf("%.2f",@total_partner.values.sum), delimiter: ',')}"]], cell_style: { border_width: 1, align: :center, font_style: :bold }, column_widths: 175, position: :center ) do
      style row(0), size: 14, background_color: "6c757d", text_color: "ffffff"
    end
    t.draw
    move_down 10
    annual_income_records = get_income_data
    width = 968/annual_income_records[0].length
    t = make_table(annual_income_records, cell_style: { border_width: 1 }, column_widths: width) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
      style row(-1), size: 12, font_style: :bold, background_color: "343a40", text_color: "ffffff", height: 30
      style column(-1), size: 12, font_style: :bold
      style column(0), size: 12, font_style: :bold
    end
    t.draw
    move_down 10
  end

  def get_income_data
    table_data = [["Type", "Advance Rate"]]
    @annual_data.each do |key, annual_income|
      data = [key, "£#{number_with_delimiter(sprintf("%.2f",annual_income["AvR"]), delimiter: ',')}"]
      (1..12).each do |i|
        if annual_income[(@date + i.month)]
          data << "£#{number_with_delimiter(sprintf("%.2f",annual_income[(@date + i.month)]), delimiter: ',')}"
        else
          data << "£#{0.0}"
        end
      end
      data << "£#{number_with_delimiter(sprintf("%.2f",@total_partner[key]), delimiter: ',')}"
      table_data << data
    end
    data = ['Total', "£#{number_with_delimiter(sprintf("%.2f",@total_avr), delimiter: ',')}"]
    (1..12).each do |i|
      table_data[0] << (@date + i.month).strftime("%b")
      data << "£#{number_with_delimiter(sprintf("%.2f",@total_month[(@date + i.month)]), delimiter: ',')}"
    end
    table_data[0] << 'Total'
    data <<  "£#{number_with_delimiter(sprintf("%.2f",@total_partner.values.sum), delimiter: ',')}"
    table_data << data
    table_data
  end

  def address
    move_down 90
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end

  def get_income
    @annual_types = Landlord.partnership_formats.keys - ['Owned']
    @landlords = Landlord.eager_load(properties: [rooms: [tenancies: :tenancy_payment_items]])
    @annual_data = {}
    @date = Date.parse("01/08/#{Date.today.year.to_s[0..1]}#{@year[0..1]}")
    @total_avr = 0.0
    @total_month = {}
    @total_partner = {}
    @annual_types.each do |annual_type|
      @total_partner[annual_type] = 0 unless @total_partner[annual_type]
      @annual_data[annual_type] = {}
      @annual_data[annual_type]["AvR"] = 0.0 unless @annual_data[annual_type]["AvR"]
      @get_landlords = @landlords.where(partnership_format: annual_type)
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
          current_date = (@date + i.month)
          price = (annual_rent && annual_rent["#{landlord.id}, #{current_date.strftime('%b, %Y')}"]) ? annual_rent["#{landlord.id}, #{current_date.strftime('%b, %Y')}"] : 0.0
          @annual_data[annual_type][current_date] = 0 unless @annual_data[annual_type][current_date]
          @total_month[current_date] = 0 unless @total_month[current_date]
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
    end
  end
end

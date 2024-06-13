require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 529
class PeopleArrearPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(ids, year, order)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => {
      normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")
      }
    )
    self.font_size = 10
    @year = year
    @order = order
    @tenancies_in_arrears = Tenancy.in_arrears.where(
      tenancy_payment_items: {
        due_date: Date.parse("01-09-20#{@year.split('/')[0]}")..Date.parse("31-08-20#{@year.split('/')[1]}")
      }
    )
    @total_people = @tenancies_in_arrears.count(:id).count
    font "Quicksand"
    upper_header
    arrears
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

  def arrears
    arrear_report
  end

  def arrear_report
    @arrear_report ||= people_arrear_report
  end

  def people_arrear_report
    text "<b>Period Ending of #{Date.today.at_end_of_month.strftime('%d %B %Y')}</b>", align: :center, size: 16, inline_format: true
    move_down 10
    t = make_table([[
      "Tenants in arrears", "Total arrears value"],
      [@total_people, "£#{number_with_delimiter(sprintf("%.2f",@tenancies_in_arrears.sum(&:total_arrears)), delimiter: ',')}"
    ]], cell_style: { border_width: 1, align: :center }, column_widths: 260) do
      style row(0), size: 12, background_color: "6c757d", text_color: "ffffff", font_style: :bold
    end
    t.draw
    move_down 30
    text "<b>Tenants In Arrears</b>", size: 14, inline_format: true
    move_down 10
    t = make_table(get_arrears_data, cell_style: { border_width: 1, align: :center}, column_widths: 435/5) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
    move_down 20
  end

  def get_arrears_data
    table_data = [["Year", "Tenant name", "Address", "Room", "Mobile", "Arrears"]]
    if @tenancies_in_arrears.present?
      @tenancies_in_arrears.each do |tenancy|
        table_data << [
          tenancy.year,
          tenancy.tenant_name,
          tenancy&.room&.property&.street,
          tenancy&.room&.number,
          tenancy.mobile,
          ("£#{number_with_delimiter(sprintf("%.2f",sprintf("%.2f", tenancy.total_arrears)), delimiter: ',')}")
        ]
      end
    else
      table_data << [{content: "No Tenants in arrears", colspan: 8, align: :left, font_style: :bold, text_color: "dc3545"}]
    end
    table_data
  end

  def address
    move_down 100
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end
end

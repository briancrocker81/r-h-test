require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 529
class LandlordStatementReportPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(property_id)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @property = Property.includes(:property_expenses, rooms: :tenancies).find_by(id: property_id)
    @landlord = @property.landlord
    @property_expenses = @property.property_expenses.for_last_month
    @property_income = TenancyPaymentItem.includes(:tenancy).where(tenancy_id: @property.tenancies.pluck(:id), due_date: Date.today.prev_month.at_beginning_of_month..Date.today.prev_month.at_end_of_month)
    @total_income = @property_income.sum(:amount_paid)
    @total_expenses = @property_expenses.sum(:amount)
    @commission = (@total_income * (@landlord.rate.to_f/100))
    @commission_vat = (@commission * 0.2)
    @total_balance = @total_income - @commission - @total_expenses - @commission_vat
    @total_arrears = @property_income.pluck(:arrears).sum(&:to_f)
    font "Quicksand"
    upper_header
    report
    footer
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

  def report
    unless @property.blank?
      landlord_statement
    end
  end

  def landlord_statement
    @landlord_statement ||= statement_report
  end

  def statement_report
    text "<b>Period Ending #{Date.today.prev_month.at_end_of_month.strftime('%d %B %Y')}</b>", align: :center, size: 16, inline_format: true
    move_down 10
    text "<b>#{@landlord.contact_name}</b>", inline_format: true, size: 14
    move_down 10
    text "<b>Property:</b> #{@property&.property_name}", inline_format: true, size: 12
    text "<b>Statement Date:</b> #{Date.today.strftime('%d %B %Y')}", inline_format: true
    move_down 10
    line_width 1
    stroke_horizontal_line(0, bounds.width)
    move_down 20
    text "<b>Income</b>", inline_format: true, size: 16
    move_down 10
    t = make_table(get_property_income, cell_style: { border_width: 1, align: :center}, column_widths: 88) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
    move_down 30
    text "<b>Expenses</b>", inline_format: true, size: 16
    move_down 10
    t = make_table(get_property_expenses, cell_style: { border_width: 1, align: :center }, column_widths: 130)  do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw

    move_down 30
    t = make_table([ ['Total Income', "£#{number_with_delimiter(sprintf("%.2f",@total_income), delimiter: ',')}"],
      ['Commission', "£#{number_with_delimiter(sprintf("%.2f",@commission), delimiter: ',')}"],
      ['VAT on commission', "£#{number_with_delimiter(sprintf("%.2f",@commission_vat), delimiter: ',')}"],
      ['Total Expenses', "£#{number_with_delimiter(sprintf("%.2f",@total_expenses), delimiter: ',')}"],
      ['Balance Due to Landlord', "£#{number_with_delimiter(sprintf("%.2f",@total_balance), delimiter: ',')}"],
      ["Total Arrears", "£#{number_with_delimiter(sprintf("%.2f",@total_arrears), delimiter: ',')}"]], position: :right) do
      style column(0), size: 12, border_width: 1, align: :right, column_widths: 150, font_style: :bold
      style column(1), border_width: 1, align: :right, column_widths: 100
      # style row(2).column(1), text_color: "dc3545"
    end
    t.draw
    move_down 30
    text "<b>Payment By direct Bank Transfer to:</b>", align: :left, inline_format: true, size: 16
    t = make_table([['Account Name:', "#{I18n.t :'company_details.account_name'}"],
                    ['Bank', "#{I18n.t :'company_details.bank'}"],
                    ['Account Number', "#{I18n.t :'company_details.bank_account_number'}"],
                    ['Sort-code', "#{I18n.t :'company_details.sort_code'}"]], cell_style: { border_width: 0}, column_widths: 150)
    t.draw
    move_down 10
    text "<b>If your balance is in a deficit/negative total, please arrange payment for the below account with in the next 7 days. Many thanks</b>", inline_format: true, size: 14
    move_down 10
  end

  def get_property_expenses
    table_data = [["Expenses", "Category", "Amount", "File"]]
     # @property_expenses.each do |expense|
     #  url = expense.file.url if expense.file.present?
     #  table_data << [expense.name, expense.category, "£#{number_with_delimiter(sprintf("%.2f",expense.amount.to_f), delimiter: ',')}", document_badge(url) ]
     # end
    if @property_expenses.count > 0
      @property_expenses.each do |expense|
        url = expense.file.url if expense.file.present?
        table_data << [expense.name, expense.category, "£#{number_with_delimiter(sprintf("%.2f",expense.amount.to_f), delimiter: ',')}", document_badge(url) ]
      end
    else
      table_data << [{content: "#{I18n.t :'reporting.no_expenses'}", colspan: 4, align: :left, font_style: :bold, text_color: "dc3545"}]
    end
    table_data
  end

  def get_property_income
    table_data = [['Room', 'Income', 'Tenant', 'Amount due', 'Amount Paid', "Arrears"]]
    if @property_income.count > 0
      @property_income.each do |income|
        table_data << [income.tenancy.room.number, income.item, income.tenancy.surname, "£#{number_with_delimiter(sprintf("%.2f",income.amount_due.to_f), delimiter: ',')}", "£#{number_with_delimiter(sprintf("%.2f",income.amount_paid.to_f), delimiter: ',')}", "£#{number_with_delimiter(sprintf("%.2f",income.arrears.to_f), delimiter: ',')}"]
      end
    else
      table_data << [{content: "#{I18n.t :'reporting.no_income'}", colspan: 6, align: :left, font_style: :bold, text_color: "dc3545"}]
    end
    table_data
  end

  def address
    move_down 100
    text "<b>#{I18n.t :'company_details.address'}</b>", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end

  def footer
    text "<b>CityLets (Plymouth) Limited</b>", align: :right, inline_format: true
    text "<b>Registered office address: #{I18n.t :'company_details.address'}</b>", align: :right, inline_format: true
    text "<b>Company registration number: #{I18n.t :'company_details.registration_number'}</b>", align: :right , inline_format: true
    text "<b>Company VAT number: #{I18n.t :'company_details.vat_number'}</b>", align: :right , inline_format: true
  end

  def document_badge(url)
    table_icon "<link href='#{url}' target='_blank'><icon color='28a745'>fas-file-pdf</icon></link>", inline_format: true
  end
end

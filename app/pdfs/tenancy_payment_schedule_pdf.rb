require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 1300
class TenancyPaymentSchedulePdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]

  def initialize(tenancy)
    super(margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @tenancy = tenancy
    @tenancies_payment_items = TenancyPaymentItem.where(tenancy_id: @tenancy.id).order(:due_date)
    @guarantor = @tenancy.guarantor
    @tenancy_avr = @tenancy.tenancy_payment_items.where(item: 'AvR').first
    font "Quicksand"
    upper_header
    display_tenant_details
    rent_additional_payments
    move_down 20
    display_schedule
    get_payment_schedule_totals
    footer
  end

  def upper_header
    logo_path =  "#{Rails.root}/app/assets/images/city-lets-trimmed.png"
    image logo_path, width: 200, height: 80, at: [165, y-30]
    # address
    # move_down 10
    move_down 80
    # line_width 2
    # stroke_horizontal_line(0, bounds.width)
    # move_down 10
  end

  def address
    move_down 100
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end

  def footer
    text "<b>CityLets (Plymouth) Limited</b>", align: :right, inline_format: true
    text "<b>Registered office address: #{I18n.t :'company_details.address'}</b>", align: :right, inline_format: true
    text "<b>Company registration number: #{I18n.t :'company_details.registration_number'}</b>", align: :right , inline_format: true
    text "<b>Company VAT number: #{I18n.t :'company_details.vat_number'}</b>", align: :right , inline_format: true
  end

  def rent_additional_payments
    if @tenancy.deposit_guarantor_amount && @tenancy.deposit_date
      t_deposit_date = @tenancy.deposit_date&.strftime("%d/%m/%Y")
      t_deposit_price = uk_price(@tenancy.deposit_guarantor_amount)
    else
      t_deposit_date = 'n/a'
      t_deposit_price = 'n/a'
    end
    if @tenancy.initial_payment
      t_initial_p_date = @tenancy.initial_payment_date&.strftime("%d/%m/%Y")
      t_initial_p_price = uk_price(@tenancy.initial_payment)
    else
      t_initial_p_date = 'n/a'
      t_initial_p_price = 'n/a'
    end
    if @tenancy_avr
      t_avr_p_date = @tenancy_avr.due_date&.strftime("%d/%m/%Y")
      t_avr_p_price = uk_price(@tenancy_avr.amount_due.to_f)
    else
      t_avr_p_date = 'n/a'
      t_avr_p_price = 'n/a'
    end

    row_data = [ ["Item:", "Payment Date", "Payment Amount (£)"],
                 ["Deposit", t_deposit_date, t_deposit_price],
                 ["Initial Payment", t_initial_p_date, t_initial_p_price],
                 ["Advanced Rent", t_avr_p_date, t_avr_p_price] ]

    t = make_table(row_data, cell_style: { border_width: 1 }, column_widths: 525/3)  do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
  end

  def rent_option(option)
    if option == "0" || option == 0
      "Termly"
    elsif option == "1" || option == 1
      "Monthly"
    elsif option == "2" || option == 2
      "Full"
    else
      'Not Defined'
    end
  end

  def display_tenant_details
    # t = make_table([[ "Name", "Contact Number", "Email", "Address", "Room"],
    #                 ["#{@tenancy.first_name} #{@tenancy.surname}", "#{@tenancy.mobile}", "#{@tenancy.email}", "#{@tenancy.room.property.number} #{@tenancy.room.property.street}", "#{@tenancy.room.number}"]],
    #                cell_style: { border_width: 1 }, column_widths: 106)  do
    #   style row(0), size: 12, background_color: "28a745", font_style: :bold
    # end
    # t.draw
    text "<b>#{@tenancy.first_name} #{@tenancy.surname}</b>", align: :center, inline_format: true, font_style: :bold, size: 14
    text "Room #{@tenancy.room.number}, #{@tenancy.room.property.number} #{@tenancy.room.property.street} #{@tenancy.room.property.postcode}", align: :center, inline_format: true, font_style: :bold, size: 12
    text "Tel: #{@tenancy.mobile}", align: :center, inline_format: true, font_style: :bold, size: 12
    text "Email: #{@tenancy.email}", align: :center, inline_format: true, font_style: :bold, size: 12

    move_down 10
  end

  def display_schedule
    move_down 10
    t = make_table(get_payment_schedule, cell_style: { border_width: 1, align: :center}, column_widths: 530/8) do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
    move_down 20
  end

  def get_payment_schedule
    table_data = [["Item", "Item Type", "Due Date", "Amount Due", "Amount Paid", "Arrears", "Date Paid", "Method"]]
    if @tenancies_payment_items.present?
      @tenancies_payment_items.each do |payment_items|
        table_data << [
          payment_items.item,
          payment_items.item_type,
          payment_items.due_date.try(:strftime, '%d %b %Y'),
          payment_items.amount_due,
          payment_items.amount_paid,
          payment_items.arrears,
          payment_items.date_paid.try(:strftime, '%d %b %Y'),
          payment_items.payment_method
        ]
      end
    else
      table_data << [{content: "No Payment Items Present", colspan: 8, align: :left, font_style: :bold, text_color: "dc3545"}]
    end
    table_data
  end

  def get_payment_schedule_totals
    total_amount_due = 0
    total_amount_paid = 0
    arrears_outstanding = 0.0
    if @tenancies_payment_items.present?
      @tenancies_payment_items.each do |payment_items|
          payment_items.due_date
          payment_items.amount_due
          payment_items.amount_paid
          payment_items.arrears

          total_amount_due += !payment_items.amount_due.nil? ? payment_items.amount_due : 0
          total_amount_paid += !payment_items.amount_paid.nil? ? payment_items.amount_paid : 0
          arrears_outstanding += payment_items.arrears.to_f
      end
    end
    t = make_table([[ "Payment Amount", "Rent payment type", "Total Amount Due", "Total Amount Paid", "Current Arrears"],
                    ["£#{@tenancy.payment_amount}",
                     "#{!@tenancy.rent_payment_option.nil? ? rent_option(@tenancy.rent_payment_option) : 'N/A'}",
                     "£#{number_with_delimiter(sprintf("%.2f",(total_amount_due*10).ceil/10.0), delimiter: ',')}",
                     "£#{number_with_delimiter(sprintf("%.2f",(total_amount_paid*10).ceil/10.0), delimiter: ',')}",
                     "£#{number_with_delimiter(sprintf("%.2f",arrears_outstanding.round(2)), delimiter: ',')}"]],
                   cell_style: { border_width: 1 }, column_widths: 106)  do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
    # text "Payment Amount: £#{@tenancy.payment_amount}"
    # move_down 10
    # text "Rent payment type: #{!@tenancy.rent_payment_option.nil? ? rent_option(@tenancy.rent_payment_option) : 'N/A'}"
    # move_down 10
    # text "Total Amount Due: £#{number_with_delimiter(sprintf("%.2f",(total_amount_due*10).ceil/10.0), delimiter: ',')}"
    # move_down 10
    # text "Total Amount Paid: £#{number_with_delimiter(sprintf("%.2f",(total_amount_paid*10).ceil/10.0), delimiter: ',')}"
    # move_down 10
    # text "Current Arrears: £#{number_with_delimiter(sprintf("%.2f",arrears_outstanding.round(2)), delimiter: ',')}"
    move_down 20
  end

  def uk_price(price)
    number_to_currency(price, :unit => "£")
  end

end
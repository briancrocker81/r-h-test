require "prawn"
require 'prawn/table'
require 'prawn/repeater'
require 'open-uri'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 529
class TenancyAgreementPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(tenancy)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @tenancy      = tenancy
    @guarantor    = @tenancy.guarantor
    @tenancy_avr  = @tenancy.tenancy_payment_items.where(item: 'AvR').first
    @company      = Company.first
    font "Quicksand"
    upper_header
    display_form
  end

  def upper_header
    logo_path =  "#{Rails.root}/app/assets/images/city-lets-trimmed.png"
    side_logo = "#{Rails.root}/app/assets/images/the-property-ombudsman-lettings.jpg"
    image logo_path, width: 170, height: 60, at: [0, y-40]
    image side_logo, width: 170, height: 60, at: [370, y-40]
    get_header
    move_down 60
  end

  # repeat(:all) do
  #   draw_text 'All pages', at: bounds.top_left
  # end

  def display_form
    unless @tenancy.blank?
      form_data
    end
  end

  def form_data
    @form_data ||= agreement_form
  end

  def agreement_form
    # Page 1
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Agreement Details: #{@tenancy.tenancy_is_nice_name}", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    text "<b>Important Notice To Tenants</b>", inline_format: true
    move_down 10
    text "This Agreement shall be legally binding. Before signing you are strongly advised to read this Agreement carefully. Please consult with a solicitor, Citizens Advice or Housing Advice Centre if you do not understand, or you are not prepared to agree to, any of the terms and conditions set out herein.", align: :justify
    move_down 20
    fill_color 'DCDCDC'
    line_width 1
    # stroke_horizontal_line(0, bounds.width)
    fill_color "212529"
    move_down 20
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "The Landlord", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    text "#{@tenancy&.room&.property&.landlord&.landlord_name} #{'/' + @tenancy&.room&.property&.landlord&.address if @tenancy&.room&.property&.landlord&.address.present? }"
    move_down 10
    if @company&.address&.present?
      comp_address = @company.address
    else
      comp_address = I18n.t :"company_details.address"
    end
    text "c/o #{comp_address}"
    move_down 5
    if @company&.phone_number&.present?
      comp_phone_number = @company.phone_number
    else
      comp_phone_number = I18n.t :"company_details.phone_number"
    end
    text "Telephone: #{comp_phone_number}"
    move_down 5
    if @company&.main_email&.present?
      comp_main_email = @company.phone_number
    else
      comp_main_email = I18n.t :"company_details.email"
    end
    text "Email: #{comp_main_email}"
    move_down 5
    if @company&.registration_number&.present?
      comp_registration_number = @company.registration_number
    else
      comp_registration_number = I18n.t :"company_details.registration_number"
    end
    text "Company registration number: #{comp_registration_number}"
    move_down 5
    if @company&.vat_number&.present?
      comp_vat_number = @company.vat_number
    else
      comp_vat_number = I18n.t :"company_details.vat_number"
    end
    text "Company VAT number: #{comp_vat_number}"
    move_down 20
    text "Tenancy Address", size: 12
    move_down 5
    if @tenancy.room.number == 'Home'
      text "#{@tenancy.room.property.property_name}, #{@tenancy.room.property.city if @tenancy.room.property.city?}, #{@tenancy.room.property.postcode if @tenancy.room.property.postcode?}"
    else
      text "Room #{@tenancy.room.number}, #{@tenancy.room.property.property_name}, #{@tenancy.room.property.city if @tenancy.room.property.city?}, #{@tenancy.room.property.postcode if @tenancy.room.property.postcode?}"
    end
    move_down 20
    text "Tenancy Key Information", size: 12
    move_down 5
    text "Fixed Term: Commencing at 15.00 HOURS on the #{@tenancy.tenancy_start.try(:strftime, "%d/%m/%Y")} and ending AT MIDDAY on the #{(@tenancy.tenancy_end).try(:strftime, '%d/%m/%Y')}"
    move_down 40
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Rent", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    # text "The total rent is £#{@tenancy.total_tenancy_value} for the Fixed Term period, payable in advance in accordance with the following <b>Rent Payment Schedule:</b>", inline_format: true
    rental_statements
    move_down 20
    rent_additional_payments
    move_down 20
    text "The Rent is payable to:", size: 10
    move_down 10
    fill_color "212529"
    get_landlord_property
    move_down 10
    draw_text page_number, at: [bounds.bottom_right, 40]

    ## page 2
    start_new_page
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Rent Payment Schedule", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    get_monthly_payments_table
    move_down 60

    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Utilities & Services", at: [10, y-40], size: 14
    fill_color "212529"
    move_down 20
    included =  @tenancy.room.property.property_utilities.where(included: true).count
    if included > 0
      text "Utilities & Services <b>included</b> with your tenancy", size: 14, inline_format: true
      move_down 10
      text "The below services are managed within your contracted rental figure. The landlord contributes a fixed financial allowance per utility/tax detailed below. The allowance is determined per utility/service and based on average usage costs at time of signing. If the cost of the utility/service alters within the tenancy period, the liability falls to the tenant/s to reimburse the landlord as required."
      move_down 5
      text "If looking at fixed/long term increases to utility/service costs, any increase to the allowances must be agreed by both parties and will simultaneously increase
      the total rental figure to compensate for the agreed upon amount."
      move_down 5
      text "For avoidance of doubt, any amount above the agreed Landlord Contribution will be the liability of the tenant and invoiced for immediate payment. If residing in a shared property (with a communal metre or charge i.e. council tax), this liability will be joint and several with any other liable tenants. This allows for any shared service with additional charges to be split equally between all liable parties."
      move_down 20
      display_included_utilities
      move_down 20
    end

    excluded =  @tenancy.room.property.property_utilities.where(included: false).count
    if excluded > 0
      text "Utilities & Services <b>excluded</b> with your tenancy", size: 14, inline_format: true
      move_down 5
      text "The Rent and tenancy does not include the below utilities. The tenant/s holds full responsibility for arranging and paying for supply and any related costs for the below utilities/services:"
      move_down 10
      display_excluded_utilities
      move_down 10
    end
    draw_text page_number, at: [bounds.bottom_right, 40]


    ## page 3
    start_new_page
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Tenancy Terms & Conditions", at: [10, y-40], size: 14
    fill_color "212529"
    move_down 20
    text "#{I18n.t :'tenancies.tenancy_terms.security.title'}", size: 14
    move_down 10
    text "#{I18n.t :'tenancies.tenancy_terms.security.p1'}"
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 5 do
      str = I18n.t :"tenancies.tenancy_terms.security.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.agreement.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 3 do
      str = I18n.t :"tenancies.tenancy_terms.agreement.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.management_regulations.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 2 do
      str = I18n.t :"tenancies.tenancy_terms.management_regulations.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.landlord_furniture.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 1 do
      str = I18n.t :"tenancies.tenancy_terms.landlord_furniture.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.security_guarantee.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 3 do
      str = I18n.t :"tenancies.tenancy_terms.security_guarantee.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    draw_text page_number, at: [bounds.bottom_right, 40]

    ## Page 4
    start_new_page
    text "#{I18n.t :'tenancies.tenancy_terms.security_deposit.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 4 do
      str = I18n.t :"tenancies.tenancy_terms.security_deposit.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.guarantee.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 5 do
      str = I18n.t :"tenancies.tenancy_terms.guarantee.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.communication.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 5 do
      str = I18n.t :"tenancies.tenancy_terms.communication.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)

    draw_text page_number, at: [bounds.bottom_right, 40]

    ## Page 5
    start_new_page
    text "#{I18n.t :'tenancies.tenancy_terms.joint_liability.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 5 do
      str = I18n.t :"tenancies.tenancy_terms.joint_liability.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)

    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.tenant_obligations.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 3 do
      str = I18n.t :"tenancies.tenancy_terms.tenant_obligations.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)

    sub_data = Array.new
    sb = 1
    while sb <= 3 do
      str = I18n.t :"tenancies.tenancy_terms.tenant_obligations.bullets.bs#{sb}"
      sub_data.push str
      sb += 1
    end
    get_sub_data(sub_data)

    list_data = Array.new
    l = 4
    while l <= 9 do
      str = I18n.t :"tenancies.tenancy_terms.tenant_obligations.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data, 4)
    draw_text page_number, at: [bounds.bottom_right, 40]

    ## Page 6
    start_new_page
    list_data = Array.new
    l = 10
    while l <= 35 do
      str = I18n.t :"tenancies.tenancy_terms.tenant_obligations.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data, 10)
    draw_text page_number, at: [bounds.bottom_right, 40]


    start_new_page
    list_data = Array.new
    l = 36
    while l <= 37 do
      str = I18n.t :"tenancies.tenancy_terms.tenant_obligations.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data, 36)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.ending_the_tenancy.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 13 do
      str = I18n.t :"tenancies.tenancy_terms.ending_the_tenancy.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.notice_period.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 4 do
      str = I18n.t :"tenancies.tenancy_terms.notice_period.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    draw_text page_number, at: [bounds.bottom_right, 40]

    ## Page 7
    start_new_page
    text "#{I18n.t :'tenancies.tenancy_terms.take_back_entitlement.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 5 do
      str = I18n.t :"tenancies.tenancy_terms.take_back_entitlement.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.supply_of_services.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 7 do
      str = I18n.t :"tenancies.tenancy_terms.supply_of_services.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 15

    text "#{I18n.t :'tenancies.tenancy_terms.rent_obligations.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 6 do
      str = I18n.t :"tenancies.tenancy_terms.rent_obligations.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 15

    draw_text page_number, at: [bounds.bottom_right, 40]

    ## Page 9
    start_new_page
    text "#{I18n.t :'tenancies.tenancy_terms.locks_keys_security.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 6 do
      str = I18n.t :"tenancies.tenancy_terms.locks_keys_security.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20

    text "#{I18n.t :'tenancies.tenancy_terms.data_protection.title'}", size: 14
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 3 do
      str = I18n.t :"tenancies.tenancy_terms.data_protection.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    draw_text page_number, at: [bounds.bottom_right, 40]

    ## Page 8
    start_new_page
    fill_color 'DCDCDC'
    line_width 1
    stroke_horizontal_line(0, bounds.width)
    fill_color "212529"
    move_down 10

    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "#{I18n.t :'tenancies.tenancy_terms.important_notice.title'}", at: [10, y-40], size: 14
    fill_color "212529"
    move_down 20
    text "#{I18n.t :'tenancies.tenancy_terms.important_notice.p1'}"
    move_down 10
    text "#{I18n.t :'tenancies.tenancy_terms.important_notice.p2'}"
    move_down 10
    text "#{I18n.t :'tenancies.tenancy_terms.important_notice.p3'}"
    move_down 10
    text "#{I18n.t :'tenancies.tenancy_terms.important_notice.p4'}"
    move_down 10
    list_data = Array.new
    l = 1
    while l <= 4 do
      str = I18n.t :"tenancies.tenancy_terms.important_notice.bullets.b#{l}"
      list_data.push str
      l += 1
    end
    get_list_data(list_data)
    move_down 20
    text "<b>Signed</b>", inline_format: true
    move_down 5
    url =  @tenancy.tenancy_agreement_signature.url if @tenancy.tenancy_agreement_signature.present?
    url = "http://localhost:3000/#{url}" unless Rails.env.production?
    image URI.open("#{url}"), width: 300, height: 100, at: [10, y-40] if url.present?
    fill_color "212529"
    move_down 100
    text "#{@tenancy.first_name} #{@tenancy.surname}"
    move_down 10
    text "<b>Signed Date</b>", inline_format: true
    move_down 5
    text @tenancy&.signed_date&.try(:strftime, '%d/%m/%Y')
    move_down 10
    text "I CONFIRM THAT I ACCEPT THIS AGREEMENT "
    fill_color @tenancy.confirm_tenancy ? "28a745" : "ffc107"
    fill_rectangle [235, y-25], 25, 18
    fill_color @tenancy.confirm_tenancy ? "ffffff" : "000000"
    draw_text "#{@tenancy.confirm_tenancy ? 'Yes' : 'No'}", at: [240, y-36], size: 10
    fill_color "212529"

    move_down 10

    if @tenancy.additional_tenants.count >= 1
      move_down 40
      additional_tenant = @tenancy.additional_tenants.first
      at_url =  additional_tenant.signature.url if additional_tenant.signature.present?
      at_url = "http://localhost:3000/#{at_url}" unless Rails.env.production?
      image URI.open("#{at_url}"), width: 300, height: 100, at: [10, y-40] if at_url.present?
      fill_color "212529"
      move_down 100
      text "#{additional_tenant.first_name} #{additional_tenant.surname}"
      text "I CONFIRM THAT I ACCEPT THIS AGREEMENT "
      fill_color additional_tenant.accept_agreement ? "28a745" : "ffc107"
      fill_rectangle [235, y-25], 25, 18
      fill_color additional_tenant.accept_agreement ? "ffffff" : "000000"
      draw_text "#{additional_tenant.accept_agreement ? 'Yes' : 'No'}", at: [240, y-36], size: 10
      fill_color "212529"
    end
    move_down 10
    # draw_text page_number, at: [bounds.bottom_right, 40]
    #
    # # page 9
    # start_new_page
    stroke_horizontal_line(0, bounds.width) # Remove if putting page break back
    move_down 10
    if @company&.name&.present?
      comp_name = @company.name
    else
      comp_name = I18n.t :"company_details.company_name"
    end
    text "#{comp_name} Signature", size: 14
    move_down 10
    text "Signed on behalf of #{comp_name}"
    move_down 10
    signature_path =  "#{Rails.root}/app/assets/images/james-signature.png"
    image signature_path, width: 335, height: 103, at: [10, y-40]
    move_down 115
    if @company&.main_contact&.present?
      main_contact = @company.main_contact
    else
      main_contact = I18n.t :"company_details.main_contact"
    end
    text "<b>#{main_contact}</b>", inline_format: true
    move_down 10
    text "<b>Signed Date</b>", inline_format: true
    move_down 5
    text @tenancy&.signed_date&.try(:strftime, '%d/%m/%Y')
    draw_text page_number, at: [bounds.bottom_right, 40]
  end

  def rental_statements
    if @tenancy.tenancy_is == 0 && @tenancy.deposit_term == 'termly'
      rent_payment_minus_avr = ((@tenancy.total_tenancy_value.to_i - @tenancy.advanced_rent_payment_amount.to_i) / @tenancy.rent_installment_term.to_i)
      text "Your rent is <b>#{uk_price(rent_payment_minus_avr)}</b> per <b>#{@tenancy.rent_installment_term} term(s)</b>, plus your advanced rent payment (if applicable).", inline_format: true
      move_down 10
      text "<b>#{uk_price(@tenancy.total_tenancy_value)}</b> Total for the Fixed Term period, payable in advance in accordance with the rent payment schedule.", inline_format: true
      move_down 10
    elsif @tenancy.tenancy_is == 0
      text "Your rent is <b>#{uk_price(@tenancy.payment_amount)}</b> for <b>#{@tenancy.number_of_payments} months</b>, plus your advanced rent payment.", inline_format: true
      move_down 10
      text "<b>#{uk_price(@tenancy.total_tenancy_value)}</b> Total for the Fixed Term period, payable in advance in accordance with the rent payment schedule.", inline_format: true
    else
      text "You total fixed term tenancy amount is <b>#{uk_price(@tenancy.payment_amount)}</b> for <b>#{@tenancy.number_of_payments} months</b>, <b>#{uk_price(@tenancy.total_tenancy_value)}</b> combined with your initial rent payment (if applicable), <b>#{uk_price(@tenancy.initial_payment)}</b>.", inline_format: true
      move_down 10
      if @tenancy.initial_payment
        payment = @tenancy.total_tenancy_value.to_i + @tenancy.initial_payment
        text "Your total value of tenancy is <b>#{uk_price(payment)}</b>.", inline_format: true
      end

      move_down 10
    end
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
      style row(0), size: 12
    end
    t.draw
  end

  def get_monthly_payments_table
    deposit_term =  @tenancy.deposit_term.to_s.titleize
    row_data = [["Item:", "Payment Date", "#{deposit_term} Payment Amount (£)",	"Number of #{deposit_term} Payments:"]]
    if @tenancy.tenancy_payment_items.size > 0
      total_number_of_monthly_payments = 0
      @tenancy.tenancy_payment_items.order(:due_date).each_with_index do |pay_item, index|
        total_number_of_monthly_payments += 1
        row_data << [ pay_item.item, pay_item&.due_date&.strftime('%d/%m/%Y'), '£'+number_with_delimiter(sprintf("%.2f",pay_item.amount_due.to_f), delimiter: ','), (total_number_of_monthly_payments.ordinalize)]
      end
    else
      row_data << [{content: "No payment items found please update tenancy rent payment option!", colspan: 4}]
    end
    t = make_table(row_data, cell_style: { border_width: 1 }, column_widths: 525/4)  do
      style row(0), size: 10
    end
    t.draw
    text ""
  end

  def display_included_utilities

    row_data = [["Service / Utility:", "Contribution", "Frequency"]]
    @tenancy.room.property.property_utilities.where(included: true).each do |utility|
      row_data << [ utility.utility_name, utility.landlord_contribution? ? uk_price(utility.landlord_contribution) : '', utility.frequency]
    end

    t = make_table(row_data, cell_style: { border_width: 1 }, column_widths: 525/3)  do
      style row(0), size: 10
    end
    t.draw
    text ""
  end

  def display_excluded_utilities
    row_data = [["Service / Utility:", ""]]
    @tenancy.room.property.property_utilities.where(included: false).each do |utility|
      row_data << [ utility.utility_name, 'Excluded']
    end
    t = make_table(row_data, cell_style: { border_width: 1 }, column_widths: 525/2)  do
      style row(0), size: 10
    end
    t.draw
    text ""
  end

  def get_landlord_property
    unless @tenancy.room.property.landlord.nil?
      landlord = check_landlord(@tenancy.room.property.landlord)
      if landlord != "not_set"
        t = make_table([
                         ["Bank Name", landlord[:bank_name], "Account name", landlord[:account_name]],
                         ["Bank address", landlord[:bank_address], "Account number", landlord[:account_number]],
                         # ["Payment ref:", "#{@tenancy.first_name.to_s[0].to_s}#{@tenancy.surname.to_s.capitalize}#{@tenancy.room.number ? 'R'+ @tenancy.room.number.to_s : ''}#{@tenancy.room.property.number}#{@tenancy.room.property.street}", "Sort code", landlord[:sort_code]],
                         ["Payment ref:", "FGJ code generated by PayProp", "Sort code", landlord[:sort_code]],
                         ["IBAN",landlord[:iban], "BIC", landlord[:bic]]
                       ], cell_style: { border_width: 1, size: 10 }, column_widths: 132 )
        t.draw
      else
        text "Not set."
      end
    end
    # text ""
  end

  def get_list_data(list_data, j = 0)
    list_data.each_with_index do |item, i|
      float do
        bounding_box [15,cursor], width: 35 do
          if j > 0
            text "#{i.to_i + j} "
          else
            text "#{i.to_i + 1} "
          end
        end
      end
      #create a bounding box for the list-item content
      bounding_box [30,cursor], width: bounds.width - 35 do
        text " #{item}", size: 10, align: :justify
      end
      #provide a space between list-items
      move_down 5
    end
  end

  def get_sub_data(sub_data, j = 0)
    sub_data.each_with_index do |item, i|
      float do
        bounding_box [25,cursor], width: 35 do
          if j > 0
            text "    #{i.to_i + j} "
          else
            text "    #{i.to_i + 1} "
          end
        end
      end
      #create a bounding box for the list-item content

      bounding_box [30,cursor], width: bounds.width - 30 do
        indent(20, 0) do # left and right padding
          text " #{item}", size: 10, align: :justify
        end
      end

      #provide a space between list-items
      move_down 5
    end
  end

  def get_header
    if @tenancy.additional_tenants.count >= 1
      additional_tenant = @tenancy.additional_tenants.first
      text "#{@tenancy.first_name.to_s.titleize} #{@tenancy.surname.to_s.titleize}", size: 14, align: :center
      text "#{additional_tenant.first_name.to_s.titleize} #{additional_tenant.surname.to_s.titleize}", size: 14, align: :center
    else
      text "#{@tenancy.first_name.to_s.titleize} #{@tenancy.surname.to_s.titleize}", size: 16, align: :center
    end
    text "#{I18n.t :'tenancies.dashboard.agreement_form.title'}", size: 14, align: :center
    if @tenancy.room.number != 'Home'
      text "#{@tenancy.room.number}", size: 10, align: :center
    end
    text "#{@tenancy.room.property.property_name}", size: 10, align: :center
  end

  def check_landlord(landlord)
    value = {}
    if ['Owned'].include? landlord.partnership_format
      value = { bank_name: landlord.bank_name, bank_address: landlord.bank_address, sort_code: landlord.bank_sort_code, account_name: landlord.account_name, account_number: landlord.bank_account_number, iban: landlord.iban, bic: landlord.bic }
    elsif ['Tenancy Partner', 'Booking Partner','Listing Partner', 'Complete Partner', 'Support Partner'].include? landlord.partnership_format
      if @company&.bank_name&.present?
        cl_bank = @company.bank_name
      else
        cl_bank = I18n.t :"company_details.bank"
      end

      if @company&.bank_address&.present?
        cl_bank_add = @company.bank_address
      else
        cl_bank_add = I18n.t :"company_details.bank_address"
      end

      if @company&.bank_account_name&.present?
        cl_acc_name = @company.bank_account_name
      else
        cl_acc_name = I18n.t :"company_details.account_name"
      end

      if @company&.bank_sort_code&.present?
        cl_sort_code = @company.bank_sort_code
      else
        cl_sort_code = I18n.t :"company_details.sort_code"
      end

      if @company&.bank_account_number&.present?
        cl_acc_num = @company.bank_account_number
      else
        cl_acc_num = I18n.t :"company_details.bank_account_number"
      end

      if @company&.bank_iban&.present?
        cl_iban = @company.bank_iban
      else
        cl_iban = I18n.t :"company_details.bank_iban"
      end

      if @company&.bank_bic&.present?
        cl_bic = @company.bank_bic
      else
        cl_bic = I18n.t :"company_details.bank_bic"
      end

      value = landlord.pay_direct ? { bank_name: landlord.bank_name, bank_address: landlord.bank_address, sort_code:
                                      landlord.bank_sort_code, account_name: landlord.account_name,
                                      account_number: landlord.bank_account_number, iban: landlord.iban,
                                      bic: landlord.bic
                                    } : { bank_name: cl_bank, bank_address: cl_bank_add, sort_code: cl_sort_code,
                                          account_name: cl_acc_name,
                                          account_number: cl_acc_num, iban: cl_iban,
                                          bic: cl_bic }
    else
      value = {bank_name: "N/A", bank_address: "N/A", sort_code: "N/A",
               account_name: "N/A", account_number: "N/A", iban: "N/A",
               bic: "N/A"
      }
    end
    return value
  end

  def rental_amount
    if @tenancy.tenancy_payment_items.count > 0
      number_with_delimiter(sprintf("%.2f",(@tenancy.tenancy_payment_items.sum(:amount_due)*10).ceil/10.0), delimiter: ',')
    else
      @tenancy.tenancy_is == 0 ? "#{number_with_delimiter(sprintf("%.2f",@tenancy.weekly_price.to_f * @tenancy.number_of_weeks.to_f), delimiter: ',')}" : "#{number_with_delimiter(sprintf("%.2f",@tenancy.monthly_price.to_f * @tenancy.number_of_months.to_f), delimiter: ',')}"
    end
  end

  def tenant_price
    @tenancy.tenancy_is == 1 ? "#{number_with_delimiter(sprintf("%.2f",@tenancy.monthly_price.to_f), delimiter: ',')} for #{@tenancy.number_of_months} months" : "#{number_with_delimiter(sprintf("%.2f",@tenancy.weekly_price.to_f), delimiter: ',')} for #{@tenancy.number_of_weeks} weeks"
  end

  def uk_price(price)
    number_to_currency(price, :unit => "£")
  end
end

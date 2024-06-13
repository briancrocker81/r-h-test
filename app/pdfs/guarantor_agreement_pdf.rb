require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
include ActionView::Helpers::NumberHelper

## Guarantor Booking form pdf
## pdf page width 529
class GuarantorAgreementPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(guarantor, tenancy)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @tenancy = tenancy
    @guarantor = guarantor
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
    move_down 100
  end

  def display_form
    unless @guarantor.blank?
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
    draw_text "Guarantor Agreement", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    text "A Guarantor Agreement is a legally binding contract between a Landlord and a person agreeing to guarantee the Tenant's performance under  the tenancy agreement throughout the fixed term, or any extension, renewal or re-grant continuation of the Agreement whether for a fixed  term or periodic tenancy and whether it is created by agreement between the landlord and the tenant or by operation of the law or otherwise.  The duty of the Guarantor is to indemnify the Landlord against any economic loss, damage or costs or other expenses arising either directly or  indirectly out of any breach of the agreement, or non-performance of contractual obligations. The Landlord's protection from financial loss is a requirement stipulated by both the Landlord's insurance company and the Landlord's  financial lenders. The Guarantor's liability is joint and several with the tenant. This means that each will be responsible for complying with the tenant's  obligations under the Agreement. The Guarantor should be a homeowner or show Citylets that that they have sufficient income to cover and  pay all reasonable costs incurred by the landlord in enforcing the guarantee and the terms of the Agreement whether for a fixed term or  periodic tenancy and whether it is created by agreement between the landlord and the tenant or by operation of the law or otherwise. This Guarantor Agreement creates a binding legal contract. If you do not fully understand the nature of this Agreement then it is recommended that you take independent legal advice before signing either from a solicitor or the local citizens Advice  Bureau for an explanation before signing it.  ", align: :justify
    move_down 30
    fill_color 'DCDCDC'
    line_width 1
    move_down 30

    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Agreement details", at: [10, y-40], size: 14
    move_down 20

    fill_color "212529"
    text "THIS GUARANTOR AGREEMENT is dated the #{@guarantor.created_at.try(:strftime, '%d/%m/%Y')}", align: :justify
    line_width 1
    move_down 10

    text "AND MADE BETWEEN THE PARTIES: -", align: :justify
    line_width 1
    move_down 10

    get_list_data(["#{@guarantor.guarantor_name} The Guarantor, or pay for any damage.", "c/o City Lets, #{I18n.t :'company_details.address'}"])
    text "This is not a deposit."
    line_width 1
    move_down 50


    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Proposed Tenant & Accommodation", at: [10, y-40], size: 14
    move_down 20

    fill_color "212529"
    t = make_table([["Name: #{@tenancy.tenant_name}", "Address: Room #{@tenancy.room.number}, #{@tenancy.room.property.property_name}"]], cell_style: { border_width: 0 }, column_widths: 260)  do
      style row(0), size: 12
    end
    t.draw
    move_down 20

    text "RENT £#{@tenancy.total_tenancy_value} For a fixed term tenancy and any subsequent renewal, or any extension, renewal or re-grant continuation of the Agreement whether for a fixed term or periodic tenancy and whether it is created by agreement between the landlord and the tenant or by operation of the law or otherwise."

    start_new_page
    move_down 50
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Guarantor's Details ", at: [10, y-40], size: 14
    draw_text "Guarantor's Employer", at: [260, y-40], size: 14
    move_down 20

    fill_color "212529"
    t = make_table([["My Name", "Employment Status"],["#{@guarantor.guarantor_name}", "#{@guarantor.employment_status.to_s.titleize}"],
      ["My Address", "Employer Name"], ["#{@guarantor.guarantor_address}", "#{@guarantor.employer_name}"],
      ["Guarantor Post code", "Employer Manager"], ["#{@guarantor.guarantor_post_code}", "#{@guarantor.employer_manager}"],
      ["Do you own your own property?", "Employer Contact"], [" #{@guarantor.own_property ? 'Yes' : 'No'}", "#{@guarantor.employer_contact}"],
      ["National Insurance Number", "Employer Address"], ["#{@guarantor.national_insurance_number}", "#{@guarantor.employer_address}"],
      ["Best Contact Number", "Employer Email"], ["#{@guarantor.contact_number}", "#{@guarantor.employer_email}"],
      ["Date of Birth", "Monthly Net Salary"], ["#{@guarantor.date_of_birth.try(:strftime, '%d/%m/%Y')}", "£#{@guarantor.net_salary}"],
      ["Relationship to proposed Tenant", "Email"], ["#{@guarantor.guarantor_relationship}", "#{@guarantor.guarantor_email}"],
      ],
      cell_style: { border_width: 0 }, column_widths: 260) do
        (0..7).each do |i|
          j = i * 2
          style row(j), size: 12, font_style: :bold
        end
      end
    t.draw

    start_new_page
    move_down 50
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "It is hereby agreed that:-", at: [10, y-40], size: 14
    move_down 20

    fill_color "212529"
    line_width 1
    move_down 10
    get_list_data(["I agree to act as Guarantor for the person noted in Box 1 above who is proposing to enter into a Tenancy Agreement and make  myself legally responsible (in the event of the proposed tenant being granted a tenancy) for payment of all outstanding rent and  other charges if the tenant defaults in payment, upon demand. I agree to fully compensate the landlord for any loss, damage,  costs or other expenses arising directly or indirectly out of any breach of the agreement", "The Guarantor will also be liable for any increase in rent agreed between the landlord and any person acting on their behalf.  3. I have read the Tenancy Agreement and understand the terms and conditions of the tenancy as set out therein. 4. I have been advised to take legal or professional advice in relation to this Guarantor Agreement and make this application in the full knowledge of the obligations in law that this Guarantor Agreement places upon me.", "All information given by me on this form is true and correct.", "In support of this document I understand the landlord may make a credit reference check or other form of check to confirm my  identity.", "I confirm that I am not an undischarged bankrupt and there is no bankruptcy petition pending against me. The guarantee shall  not be revocable by the guarantor nor will it be rendered unenforceable by the Guarantor's death or bankruptcy.  8. I understand that my obligations under this Agreement shall commence on the Tenancy Commencement Date and shall  continue throughout the period that the property is occupied by the tenant or any licensee and is not limited the term  specified in the agreement. The Guarantee will continue throughout the tenancy or any extension/renewal in the property  or other properties, or re-grant continuation of the Agreement whether for a fixed term or periodic tenancy and whether it  is created by agreement between the landlord and the tenant or by operation of the law or otherwise.", "In the event of my death, my personal representatives or administrators shall notify the Landlord as soon as practicable and  my estate shall assume liability for the Guarantor's obligations under this Agreement."])
    move_down 20
    draw_text "CONSIDERATION", at: [0, y-40], size: 10
    move_down 10
    text "The consideration for this guarantee is that the landlord agrees to let the property to the tenant(s)."
    move_down 20
    draw_text "GUARANTEE", at: [0, y-40], size: 10
    move_down 10
    text "The guarantor covenants with the landlord that the tenant will pay all rent made payable by and perform and observe all covenants,  conditions and obligations contained in the tenancy agreement to be performed and observed by the tenant and will compensate the landlord  in full on demand made in writing within 7 days for all liabilities incurred by the tenant in respect of the obligations and for all losses, damages,  costs and expenses thereby arising or incurred by the landlord."
    move_down 20
    draw_text "WAIVER", at: [0, y-40], size: 10
    move_down 10
    text "The landlord may release or compromise the tenant's liability under the obligations or grant to either the tenant or the guarantor time or  other indulgence without affecting the guarantor liability under this guarantee."
    move_down 20


    draw_text "GUARANTOR SIGNATURE", at: [0, y-40], size: 10
    move_down 30
    url = @guarantor.guarantor_signature.url if @guarantor.guarantor_signature.present?
    url = "http://localhost:3000/#{url}" unless Rails.env.production?
    image URI.open("#{url}"), width: 300, height: 100, at: [10, y-40] if url.present?
    move_down 100


    fill_color "212529"
    text "I CONFIRM THAT I ACCEPT THIS AGREEMENT "
    fill_color @guarantor.confirm_guarantor ? "28a745" : "ffc107"
    fill_rectangle [220, y-25], 25, 18
    fill_color @guarantor.confirm_guarantor ? "ffffff" : "000000"
    draw_text "#{@guarantor.confirm_guarantor ? 'Yes' : 'No'}", at: [225, y-36], size: 10
    fill_color "212529"

    start_new_page
    move_down 50
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Photographic I.D", at: [10, y-40], size: 14
    move_down 60
    photo_url = @guarantor.photo_id.url if @guarantor.photo_id.present?
    document_badge(true, 'fas-file', 'Photo Id', ApplicationController.helpers.asset_url(photo_url)) if photo_url.present?
    move_down 120

    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Utility Bill", at: [10, y-40], size: 14
    move_down 60
    utility_bill = @guarantor.utility_bill.url if @guarantor.utility_bill.present?
    document_badge(true, 'fas-file', 'Utility Bill', ApplicationController.helpers.asset_url(utility_bill)) if utility_bill.present?
  end

  def get_table_row_data
    row_data = [["DEPOSIT/ GUARANTOR AMOUNT (£):", "#{@tenancy.deposit_term.to_s.upcase} PAYMENT AMOUNT (£)",	"NUMBER OF #{@tenancy.deposit_term.to_s.upcase} PAYMENTS:"]]
    if @tenancy.tenancy_payment_items.size > 0
      total_number_of_monthly_payments = 0
      @tenancy.tenancy_payment_items.each_with_index do |pay_item, index|
        total_number_of_monthly_payments += 1 if index >= 1
        row_data << [ pay_item.item, '£'+number_with_delimiter(sprintf("%.2f",pay_item.amount_due.to_f), delimiter: ','), ((total_number_of_monthly_payments.ordinalize) if index >= 1)]
      end
    else
      row_data << [{content: "No payment items found please update tenancy rent payment option!", colspan: 3}]
    end
    t = make_table(row_data, cell_style: { border_width: 1 }, column_widths: 175)  do
      style row(0), size: 12
    end
    t.draw
    text ""
  end

  def get_list_data(list_data, j = 0)
    list_data.each_with_index do |item, i|
      float do
        bounding_box [15,cursor], width: 30 do
          if j > 0
            text "#{i.to_i + j} "
          else
            text "#{i.to_i + 1} "
          end
        end
      end
      #create a bounding box for the list-item content
      bounding_box [25,cursor], width: bounds.width - 30 do
        text " #{item}", size: 10, align: :justify
      end
      #provide a space between list-items
      move_down 5
    end
  end

  def get_header
    text "GUARANTOR AGREEMENT", size: 16, align: :center
    text "Room #{@tenancy.room.number}, #{@tenancy.room.property.property_name}", size: 10, align: :center
  end

  def get_declaration
    fill_color @guarantor.own_property ? "28a745" : "bd2130"
    fill_rectangle [70, y-210], 25, 18
    fill_color @guarantor.own_property ? "ffffff" : "000000"
    draw_text ("#{@guarantor.own_property ? '  Yes' : '  No'}"), at: [70, y-222], size: 10
    fill_color "212529"
    text ""
  end

  def document_badge (bool, icon, name, url)
    fill_color bool ? "28a745" : "dc3545"
    icon icon, size: 20
    formatted_text([{text: name, link: url }]) if url.present?
  end

  def total_rental_amount
    if @tenancy.tenancy_payment_items.count > 0
      number_with_delimiter(sprintf("%.2f",(@tenancy.tenancy_payment_items.sum(:amount_due)*10).ceil/10.0), delimiter: ',')
    else
      @tenancy.tenancy_is == 0 ? number_with_delimiter(sprintf("%.2f",(@tenancy.weekly_price.to_f * @tenancy.number_of_weeks.to_f).ceil), delimiter: ',') : number_with_delimiter(sprintf("%.2f",(@tenancy.monthly_price.to_f * @tenancy.number_of_months.to_f).ceil), delimiter: ',')
    end
  end

end

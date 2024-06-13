require "prawn"
require 'prawn/table'
require 'open-uri'
include ActionView::Helpers::NumberHelper

## Tenancy Booking form pdf
## pdf page width 529
class TenancyBookingPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(tenancy)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @tenancy = tenancy
    @guarantor = @tenancy&.guarantor
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
    move_down 50
  end

  def get_header
    # text "#{@tenancy.first_name.to_s.titleize} #{@tenancy.surname.to_s.titleize}", size: 16, align: :center
    if @tenancy.additional_tenants.count >= 1
      additional_tenant = @tenancy.additional_tenants.first
      text "#{@tenancy.first_name.to_s.titleize} #{@tenancy.surname.to_s.titleize}", size: 14, align: :center
      text "#{additional_tenant.first_name.to_s.titleize} #{additional_tenant.surname.to_s.titleize}", size: 14, align: :center
    else
      text "#{@tenancy.first_name.to_s.titleize} #{@tenancy.surname.to_s.titleize}", size: 14, align: :center
    end
    text "#{I18n.t :'tenancies.dashboard.booking_form.title'}", size: 16, align: :center
    unless @tenancy.room.number.nil?
      text "Room #{@tenancy.room.number}, #{@tenancy.room.property.property_name}", size: 10, align: :center
    end
  end

  def display_form
    unless @tenancy.blank?
      form_data
    end
  end

  def form_data
    @form_data ||= booking_form
  end

  def number_of_months(start_date, end_date)
    ((end_date - start_date).to_f / 365 * 12).round
  end

  def booking_form
    # Page 1
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Personal Details", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    t = make_table([["Tenants Firstname(s)", "Tenant Surname"],["#{@tenancy.first_name}", "#{@tenancy.surname}"], ["Tenant Date of Birth", "Tenant Mobile"], ["#{@tenancy.dob.try(:strftime, '%d %B %Y')}", "#{@tenancy.mobile}"], ["Tenant Email", "Tenant Nationality"], ["#{@tenancy.email}", "#{@tenancy.nationality}"], ["Tenancy Year", "Criminal Record declaration"], ["#{@tenancy.year}", "Do you have a criminal record? #{get_declaration}"]], cell_style: { border_width: 0 }, column_widths: 260)  do
      style row(0), size: 12
      style row(2), size: 12
      style row(4), size: 12
      style row(6), size: 12
    end
    t.draw

    move_down 50
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Tenancy Key Details", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    if @tenancy.number_of_months.blank?
      months = number_of_months(@tenancy.tenancy_start, @tenancy.tenancy_end)
    else
      months = @tenancy.number_of_months
    end

    if @tenancy&.tenancy_is == 0
      t = make_table([[ "Tenancy dates", "Payment type", "Number of weeks"],
        ["#{@tenancy.tenancy_start.try(:strftime, "%d/%m/%Y")} - #{@tenancy.tenancy_end.try(:strftime, "%d/%m/%Y")}",
         "#{@tenancy.deposit_term.to_s.capitalize()}",
         "#{@tenancy.number_of_weeks}"]], cell_style: { border_width: 0 }, column_widths: 172)  do
      style row(0), size: 12
      end
    else
      t = make_table([[ "Tenancy dates", "Payment type", "Number of months"],
        ["#{@tenancy.tenancy_start.try(:strftime, "%d/%m/%Y")} - #{@tenancy.tenancy_end.try(:strftime, "%d/%m/%Y")}",
         "#{@tenancy.deposit_term.to_s.capitalize()}",
         "#{months}"]], cell_style: { border_width: 0 }, column_widths: 172) do
      style row(0), size: 12
      end
    end

    t.draw
    move_down 50

    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Emergency Contact Details (if different from Guarantor)", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    t = make_table([["Emergency contact name", "Emergency contact address"], ["#{@tenancy.emergency_contact_name}", "#{@tenancy.emergency_contact_address}"], ["Emergency contact number", "Emergency contact postcode"], ["#{@tenancy.emergency_contact_number}", "#{@tenancy.emergency_contact_postcode}"]], cell_style: { border_width: 0 }, column_widths: 260)  do
      style row(0), size: 12
      style row(2), size: 12
    end
    t.draw
    move_down 50

    guarantor_data if @guarantor.present?

    start_new_page
    get_student_course_detail if @tenancy.tenancy_is == 0 && @tenancy.student_course_detail.present?
    get_professional_detail if @tenancy.tenancy_is == 1 && @tenancy.professional_detail.present?

    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Deposit / Advanced Rent", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    text "I hereby authorise CityLets to debit my account via my debit card below. Please take the agreed amount on receipt of this form, or at your nearest convenience. This will be used for the following according to the above agreement:", align: :justify
    move_down 10
    bounding_box [30,cursor], width: bounds.width - 35 do
      text "Used as my Holding Fee (a maximum of 1 weeks rent) prior to documents being completed.", size: 10, align: :justify
      text "Once documents completed, used as a Deposit for the duration of my tenancy", size: 10, align: :justify
      text "Once documents completed, used as an Advanced Rent and deducted equally from my future rent payments", size: 10, align: :justify
    end
    move_down 10
    text "I understand that by paying this holding fee I am making a commitment and reserving the property. I understand that I will forfeit the equivalent of one weeks rent if I do not proceed with the booking and complete the relevant documents within 15 days of being sent.", align: :justify
    move_down 10
    text "This will cover CityLets administration costs, if failing to complete the tenancy agreement or supporting documents and take up occupancy.", align: :justify
    move_down 10
    text "I understand that I have a 15 day deadline for agreement, from when I submit the form and pay the holding deposit to completing the tenancy agreement.", align: :justify
    move_down 10
    if @tenancy&.tenancy_is == 0
      t = make_table([["Advanced Rent Payment Amount", "Advanced Rent Payment Date"], ["£#{number_with_delimiter(sprintf("%.2f",@tenancy.advanced_rent_payment_amount.to_f), delimiter: ',')}", "#{@tenancy&.advanced_rent_payment_date&.strftime("%d/%m/%Y")}"]], cell_style: { border_width: 0 }, column_widths: 260)  do
        style row(0), size: 12
      end
      t.draw
      move_down 10
    end
    t = make_table([["Deposit Amount", "Deposit Date"],
      ["£#{number_with_delimiter(sprintf("%.2f",@tenancy.deposit_guarantor_amount.to_f), delimiter: ',')}", "#{@tenancy&.deposit_date&.strftime("%d/%m/%Y")}"]], cell_style: { border_width: 0 }, column_widths: 260)  do
      style row(0), size: 12
    end

    t.draw
    move_down 10
    text "Please note:"
    move_down 10
    text "Once the payment has been collected, Citylets will retain your transaction receipt for collection by you from our office for 14 days after in which in will then be placed in confidential waste.", align: :justify
    move_down 10
    text "In view of the nature of the information provided above, Citylets will retain all authorities in a locked safe thus avoiding any confidentiality or security breaches.", align: :justify
    move_down 50
    get_student_rules if @tenancy&.tenancy_is == 0
    get_professional_rules if @tenancy&.tenancy_is == 1

    ## Page 3
    start_new_page
    move_down 50
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Special Conditions", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    if @tenancy.special_conditions && @tenancy.special_conditions != ''
      text @tenancy.special_conditions
    else
      text "n/a"
    end
    move_down 10
    text "<b>Please note:</b>", inline_format: true
    text "The special conditions will need to be confirmed in writing by the landlord or agent."
    text "If you have NOT discussed these special conditions prior to booking please email separately."
    move_down 20

    fill_color 'DCDCDC'
    line_width 1
    stroke_horizontal_line(0, bounds.width)
    fill_color "000000"
    move_down 50
    text "Tenant Signature"
    url = @tenancy.signature.url if @tenancy.signature.present?
    url = "http://localhost:3000/#{url}" unless Rails.env.production?
    image URI.open("#{url}"), width: 300, height: 100, at: [10, y-20] if url.present?
    move_down 100
    fill_color "212529"
    text "I CONFIRM THAT I ACCEPT THIS AGREEMENT "
    fill_color @tenancy.confirm_tenancy ? "28a745" : "ffc107"
    fill_rectangle [235, y-25], 25, 18
    fill_color @tenancy.confirm_tenancy ? "ffffff" : "000000"
    draw_text "#{@tenancy.confirm_tenancy ? 'Yes' : 'No'}", at: [240, y-36], size: 10
    fill_color "212529"
  end

  def guarantor_data
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Guarantor Details", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    t = make_table([["Guarantor Name", "Guarantor Address", "Guarantor Postcode"], ["#{@guarantor.guarantor_name}", "#{@guarantor.guarantor_address}", "#{@guarantor.guarantor_post_code}"], ["Guarantor Email", "Guarantor Mobile", "Guarantor Relationship to Tenant"], ["#{@guarantor.guarantor_email}", "#{@guarantor.guarantor_mobile}", "#{@guarantor.guarantor_relationship}"]], cell_style: { border_width: 0 }, column_widths: 175) do
      style row(0), size: 12
      style row(2), size: 12
    end
    t.draw
  end

  def get_rules
    fill_color "212529"
    ["This is not applicable for 1 bedroom apartments or studios.", "I understand that Citylets will continue to actively market this complete property to groups of students until over 50% of rooms are booked..", "If Citylets do secure a booking from a group, they agree to inform me as quickly as possible, so they can arrange to show a selection of rooms of a similar or better standard, for an equal rent to that agreed.", "If none of these rooms meet my expectations, I understand that I will qualify for a refund of all monies paid"].each do |item|
      float do
        bounding_box [15,cursor], width: 10 do
          text "•"
        end
      end
      #create a bounding box for the list-item content
      bounding_box [25,cursor], width: bounds.width do
        text item, align: :justify
      end
      #provide a space between list-items
      move_down 5
    end
  end

  def get_declaration
    fill_color @tenancy.criminal_record ? "28a745" : "ffc107"
    fill_rectangle [420, y-210], 25, 18
    fill_color @tenancy.criminal_record ? "ffffff" : "000000"
    draw_text ("#{@tenancy.criminal_record ? 'Yes' : 'No'}"), at: [425, y-222], size: 10
    fill_color "212529"
    text ""
  end

  def get_student_course_detail
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Student Course Details", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    t = make_table([[ "Studying at", "Studying course student number"], ["#{@tenancy&.student_course_detail&.studying_at}", "#{@tenancy&.student_course_detail&.student_id_number}"]], cell_style: { border_width: 0 }, column_widths: 172)  do
      style row(0), size: 12
    end
    t.draw
    move_down 10
    t = make_table([[ "Studying course name" , "Course Start", "Course End" ], ["#{@tenancy&.student_course_detail&.course}", "#{@tenancy&.student_course_detail&.course_start&.strftime('%Y')}", "#{@tenancy&.student_course_detail&.course_end&.strftime('%Y')}"]], cell_style: { border_width: 0 }, column_widths: 172)  do
      style row(0), size: 12
    end
    t.draw
    move_down 50
  end

  def get_professional_detail
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Professional Details", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    t = make_table([[ "Working at", "Job Title"], ["#{@tenancy&.professional_detail&.working_at}", "#{@tenancy&.professional_detail&.job_title}"]], cell_style: { border_width: 0 }, column_widths: 172)  do
      style row(0), size: 12
    end
    move_down 10
    t.draw
    t = make_table([[ "Salary", "Salary type", "Employment type"],
                    ["#{@tenancy&.professional_detail&.salary}", "#{@tenancy.professional_detail&.salary_type_nice_name(@tenancy.professional_detail&.salary_type)}", "#{@tenancy.professional_detail&.employment_type_nice_name(@tenancy.professional_detail&.employment_type)}"]],
                   cell_style: { border_width: 0 }, column_widths: 172)  do
      style row(0), size: 12
    end
    t.draw
    move_down 20

    if @tenancy.professional_detail&.receive_benefits == true
      text "<b>Benefit / Financial help Details</b>", inline_format: true
      move_down 10
      text "#{@tenancy&.professional_detail&.benefit_details}"
      move_down 20
    end
    move_down 30
    # draw_text "Working at", at: [10, y-40], size: 14
    # move_down 10
    # text "#{@tenancy&.professional_detail&.working_at}"
    # move_down 10
    # draw_text "Job title", at: [10, y-40], size: 14
    # move_down 10
    # text "#{@tenancy&.professional_detail&.job_title}"
    # move_down 10

  end

  def salary_type_nice_name(option)
    if option == "0" || option == 0
      "Annual"
    elsif option == "1" || option == 1
      "Monthly"
    elsif option == "2" || option == 2
      "Weekly"
    else
      'Not Defined'
    end
  end
  def employment_type_nice_name(option)
    if option == "0" || option == 0
      "Full Time"
    elsif option == "1" || option == 1
      "Part Time"
    elsif option == "2" || option == 2
      "Temporary"
    else
      'Not Defined'
    end
  end

  def get_student_rules
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "50% Rule", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    text "<b>THIS CLAUSE IS ONLY RELEVANT TO PROPERTIES BOOKED ON A STUDENT CYCLE (SEPTEMBER START DATE)</b>", inline_format: true
    move_down 10
    text ""
    get_rules
  end

  def get_professional_rules
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "What else we will need", at: [10, y-40], size: 14
    move_down 20
    text "To support your booking form you will also need to send us:"
    list_point
  end

  def list_point
    fill_color "212529"
    ["Passport (If you don’t have a passport you’ll need to send 2 documents I.e. Driving licence and birth certificate)", "3 Months bank statements or Pay Slips"].each do |item|
      float do
        bounding_box [15,cursor], width: 10 do
          text "•"
        end
      end
      #create a bounding box for the list-item content
      bounding_box [25,cursor], width: bounds.width do
        text item, align: :justify
      end
      #provide a space between list-items
      move_down 5
    end
  end
end

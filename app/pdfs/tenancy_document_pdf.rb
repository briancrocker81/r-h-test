require "prawn"
require 'prawn/table'
require 'prawn/icon'
## Tenancy Booking form pdf

class TenancyDocumentPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(tenancy)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf")})
    self.font_size = 10
    @tenancy = tenancy
    @guarantor = @tenancy.guarantor
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
    unless @tenancy.blank?
      form_data
    end
  end

  def form_data
    @form_data ||= document_compliance
  end

  def document_compliance

    # Page 1
    fill_color "00B050"
    fill_rectangle [0, y-20], 529, 30
    fill_color "ffffff"
    draw_text "Compliance documents", at: [10, y-40], size: 14
    move_down 20
    fill_color "212529"
    text "Please download each document. Read them carefully before agreeing the terms.", align: :justify
    move_down 10
    text "Proprty's compliance documents:", align: :justify
    move_down 20
    get_property_compliance_document
    move_down 30
    fill_color "212529"
    text "Tenancy compliance documents:"
    move_down 20
    get_tenancy_compliance_document
    move_down 30
    fill_color "212529"
    text "I HAVE CONFIRM I HAVE HAD SIGHT OF ALL OF THE ABOVE DOCUMENT"
    fill_color @tenancy.read_doc ? "28a745" : "ffc107"
    fill_rectangle [350, y-25], 25, 18
    fill_color @tenancy.read_doc ? "ffffff" : "000000"
    draw_text "#{@tenancy.read_doc ? 'Yes' : 'No'}", at: [355, y-36], size: 10
    fill_color "212529"
  end

  def get_header
    if @tenancy.additional_tenants.count >= 1
      additional_tenant = @tenancy.additional_tenants.first
      text "#{@tenancy.first_name.to_s.titleize} #{@tenancy.surname.to_s.titleize}", size: 14, align: :center
      text "#{additional_tenant.first_name.to_s.titleize} #{additional_tenant.surname.to_s.titleize}", size: 14, align: :center
    else
      text "#{@tenancy.first_name.to_s.titleize} #{@tenancy.surname.to_s.titleize}", size: 14, align: :center
    end
    text "#{I18n.t :'tenancies.dashboard.document_confirmation_form.title'}", size: 16, align: :center
    text "Room #{@tenancy.room.number}, #{@tenancy.room.property.property_name}", size: 10, align: :center
  end

  def get_property_compliance_document
    @tenancy.room.property.compliance_documents.each do |doc|
      if doc.document_name.present? && doc.document_file.present?
        document_badge((doc.document_file != '' && !doc.document_file.nil?) ? true : false, 'fas-file-pdf', doc.document_name.split('_').map(&:capitalize).join(' '))
        # document_badge((doc.document_file != '' && !doc.document_file.nil?) ? true : false, 'fas-file-pdf', doc.document_name.split('_').map(&:capitalize).join(' '), ApplicationController.helpers.asset_url(doc.document_file.url))
      end
    end

  end

  def get_tenancy_compliance_document
    @tenancy.tenancy_documents.each do |doc|
      if doc.document_name.present? && doc.document_file.present?
        document_badge((doc.document_file != '' && !doc.document_file.nil?) ? true : false, 'fas-file-pdf', doc.document_name.split('_').map(&:capitalize).join(' '))
        # document_badge((doc.document_file != '' && !doc.document_file.nil?) ? true : false, 'fas-file-pdf', doc.document_name.split('_').map(&:capitalize).join(' '), ApplicationController.helpers.asset_url(doc.document_file.url))
      end
    end
  end

  # def document_badge (bool, icon, name, url)
  def document_badge (bool, icon, name)
    fill_color bool ? "28a745" : "dc3545"
    icon icon, size: 20
    # formatted_text([{text: name, link: url }]) if url.present? && name.present?
    formatted_text([{text: name}]) if name.present?
  end

end

require "prawn"
require 'prawn/table'
require 'open-uri'
require 'prawn/icon'
## Tenancy Booking form pdf
## pdf page width 529
class ComplianceDocumentPdf < Prawn::Document
  PAGE_MARGIN = [40, 40, 40, 40]
  # legal - 612.00 x 1008.00
  def initialize(report_for)
    super(:page_size => "LEGAL",  margin: PAGE_MARGIN, page_layout: :portrait)
    self.font_families.update("Quicksand" => { normal: Rails.root.join("vendor/assets/fonts/Quicksand-Medium.ttf"), bold: Rails.root.join("vendor/assets/fonts/Quicksand-Bold.ttf")})
    self.font_size = 10
    @compliance_documents = ComplianceDocument.includes(:property).all
    @all_count = @compliance_documents.count
    @title = "All Compliance Documents"
    expired = @compliance_documents.where('DATE(document_expiry) < ?', Time.now)
    next_month_expired = @compliance_documents.where('extract(month from document_expiry) = ? AND extract(year from document_expiry) = ?', (Time.now + 1.month).strftime('%m'), (Time.now + 1.month).strftime('%Y'))
    next_three_months_expired = @compliance_documents.where('extract(month from document_expiry) BETWEEN ? AND ?', (Time.now).strftime('%m'), (Time.now + 3.month).strftime('%m')).where('extract(year from document_expiry) BETWEEN ? AND ?', (Time.now).strftime('%Y'), (Time.now + 3.month).strftime('%Y'))
    @expired_count = expired.count
    @next_month_expired_count = next_month_expired.count
    @next_three_months_expired_count = next_three_months_expired.count
    @missing = @compliance_documents.where('document_name = ? or document_file = ? or document_name = ? or document_file = ?', nil, nil, '', '').count
    @report_for = report_for
    if @report_for == 'expired'
      @compliance_documents = expired
      @title = "Expired Compliance Documents"
      @missing = expired.where('document_name = ? or document_file = ? or document_name = ? or document_file = ?', nil, nil, '', '').count
    elsif @report_for == 'next_month_expired'
      @compliance_documents = next_month_expired
      @title = "Next month expired Compliance Documents"
      @missing = next_month_expired.where('document_name = ? or document_file = ? or document_name = ? or document_file = ?', nil, nil, '', '').count
    elsif @report_for == 'next_three_months_expired'
      @compliance_documents = next_three_months_expired
      @title = "Next three months expired Compliance Documents"
      @missing = next_three_months_expired.where('document_name = ? or document_file = ? or document_name = ? or document_file = ?', nil, nil, '', '').count
    end
    @compliance_documents = @compliance_documents.order('document_expiry asc')
    font "Quicksand"
    upper_header
    compliance_document_report
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

  def address
    move_down 100
    text "<b>#{I18n.t :'company_details.address'}", align: :center, inline_format: true
    text "<b>Tel: #{I18n.t :'company_details.phone_number'}</b>", align: :center , inline_format: true
  end

  def compliance_document_report
    unless @compliance_documents.blank?
      compliance_document
    end
  end

  def compliance_document
    @compliance_document ||= compliance_document_data
  end

  def compliance_document_data
    text "<b>#{@title}</b>", size: 16, align: :center, inline_format: true
    move_down 20
    t = make_table(get_key_figures, cell_style: { border_width: 1, align: :center }, column_widths: 529/5, position: :center) do
      style row(0), size: 14, background_color: "6c757d", text_color: "ffffff"
    end
    t.draw
    move_down 20
    text "Compliance Documents", size: 14
    move_down 10
    t = make_table(get_compliance_data, cell_style: { border_width: 1, align: :center }, column_widths: 529/3)  do
      style row(0), size: 12, background_color: "28a745", font_style: :bold
    end
    t.draw
  end

  def get_key_figures
    table_data = [
      ['All', 'Expired', 'Expired Certs Next Month', 'Expired Certs Next Three Months', 'Missing'],
      [@all_count, @expired_count, @next_month_expired_count, @next_three_months_expired_count, @missing]
    ]
    if @report_for == 'next_month_expired'
      table_data = [
        ['All', 'Expired', 'Expired Certs Next Month', 'Expired Certs Next Three Months', 'Missing'],
        [@all_count, @expired_count, @next_month_expired_count, @next_three_months_expired_count, @missing]
      ]
    elsif @report_for == 'next_three_months_expired'
      table_data = [
        ['All', 'Expired', 'Expired Certs Next Month', 'Expired Certs Next Three Months', 'Missing'],
        [@all_count, @expired_count, @next_month_expired_count, @next_three_months_expired_count, @missing]
      ]
    end
    table_data
  end

  def get_compliance_data
    table_data = [["Property", "Document", "Expired Date"]]
    @compliance_documents.each do |doc|
      table_data << [(doc.property.present? ? doc.property.property_name : "N/A"), doc.document_name, doc.document_expiry ]
    end
    table_data
  end
end

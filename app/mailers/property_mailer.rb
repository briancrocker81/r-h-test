class PropertyMailer < ApplicationMailer
  require 'open-uri'

  def send_compliance_documents(property_id, tenancy_id)
    @property = Property.find(property_id)
    @tenancy = @property.tenancies
                        .where('Date(tenancy_start) <= ? and Date(tenancy_end) > ?', Date.today, Date.today)
                        .where(booking_status: 'complete')
                        .find(tenancy_id)

    @property.compliance_documents.each_with_index do |comp_doc, i|
      next unless comp_doc.document_file.present?

      if Rails.env.development?
        attachments[comp_doc.document_file.path.split('/').last] = File.read(comp_doc.document_file.path)
      else
        attachments[comp_doc.document_file.path.split('/').last] = open(comp_doc.document_file.url) { |f| f.read }
      end
    end
    mail(to: @tenancy.email, subject: "Compliance Documents for #{@property.display_address}")
  end

  def send_property_mail(mail, property_report_id)
    @property_report = Report.monthly.full_listing_monthly.find_by(id: property_report_id)
    attachments["full_listing_monthly(#{Date.today.strftime('%b_%Y')})_.pdf"] = AttachmentReaderService.read(@property_report.report.url) if @property_report.report
    mail(to: mail, subject: 'Property Report')
  end
end

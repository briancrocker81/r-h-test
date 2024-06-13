class LandlordMailer < ApplicationMailer
  require 'open-uri'

  def send_statement_report_mail(statement_id)
    @landlord_statement_report = Report.landlord_statement.includes(:landlord, :property).find_by(id: statement_id)
    @landlord = @landlord_statement_report.landlord
    @property = @landlord_statement_report.property
    if @landlord && @landlord.email
      term = @landlord_statement_report.term_type == 'yearly' ? "Annual" : 'Monthly'
      return unless @landlord_statement_report.report

      attachment_url = @landlord_statement_report.report.url
      attachment_url = "public/#{attachment_url}" if Rails.env.development?
      attachments["#{term}_landlord_statement_#{@property&.property_name}.pdf"] = AttachmentReaderService.read(attachment_url)

      @property&.property_expenses&.for_last_month&.each do |expense|
        next unless expense.file&.file.present?

        attachment_url = expense.file.url
        attachment_url = "public/#{attachment_url}" if Rails.env.development?
        attachments[expense.file.file.filename] = AttachmentReaderService.read(attachment_url)
      end

      @landlord_statement_report.update_columns({mail_sent: true, mail_sent_at: DateTime.now })
      mail(to: @landlord.email, subject: "#{@landlord.contact_name}, #{@property&.property_name}")
    end
  end

  def send_arrear_mail(mail, ids, year, order)
    attachments["people_arrears_#{Date.today.strftime('%d_%m_%Y')}.pdf"] = PeopleArrearPdf.new(ids, year, order).render
    mail(to: mail, subject: 'Arrears Report')
  end

  def send_booking_report(year, landlord_id)
    @landlord = Landlord.find_by(id: landlord_id)
    if @landlord
      attachments["booking_report_#{Date.today.strftime('%d_%m_%Y')}.pdf"] = LandlordBookingReportPdf.new(@landlord, year).render
      mail(to: @landlord.email, subject: "Landlord #{@landlord.landlord_name} Booking Report")
    end
  end
end

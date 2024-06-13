## Generate and send statement to landlord

## rails landlords:generate_statement_report
namespace :landlords do
  desc 'generate landlord statement report'
  task generate_statement_report: :environment do
    Property.generate_monthly_landlord_reports
  end

  desc 'regenerate landlord statement reports'
  task regenerate_all_statement_reports: :environment do
    Property.generate_monthly_landlord_reports(regenerate: true)
  end

  # rails landlords:send_lanlord_statement_email
  desc 'Send landlord statement to lanlord'
  task send_lanlord_statement_email: :environment do
    if ManageAutomationMail.where(mail_type: 'Landlord Mailer', automation: true).where('mail_methods LIKE ?', '%send_statement_report_mail%').present?
      @landlord_statement_reports = Report.monthly.landlord_statement.where('DATE(created_at) between ? and ? and mail_sent = ? and month = ?', Date.today.at_beginning_of_month, Date.today.at_end_of_month, false, Date.today.prev_month.month)
      p " ========count #{@landlord_statement_reports.count}======"
      @landlord_statement_reports.each do |report|
        begin
          LandlordMailer.send_statement_report_mail(report.id).deliver_now
        rescue Net::SMTPSyntaxError => e
          puts "Net::SMTPSyntaxError hit when processing email for report ##{report.id}"
          puts e.message
        end
      end
      puts 'Mail has been sent successfully'
    end
  end

  ## generate the annual report
  ## rails landlords:generate_annual_statement_report
  # desc 'generate landlord annual report'
  # task :generate_annual_statement_report, [:start_date, :end_date, :property_id] => :environment do |t, args|
  #   start_date = args.start_date
  #   end_date = args.end_date
  #
  #   # Property.joins(:landlord, :property_expenses, rooms: :tenancies).uniq.each do |property|
  #   @property = Property.find_by(id: args.property_id)
  #   if @property
  #     p "====#{@property&.property_name}====="
  #     date = start_date.to_date
  #     year = date.strftime('%y').to_i
  #     month = date.strftime('%m').to_i
  #     statement_year = "#{year - 1}/#{year}"
  #     statements = @property.reports.yearly.landlord_statement.where(year: statement_year)
  #     unless statements.count > 0
  #       report = LandlordAnnualStatementReportPdf.new(@property.id, start_date, end_date).render
  #       file = StringIO.new(report) #mimic a real upload file
  #       file.class.class_eval { attr_accessor :original_filename, :content_type } #add attr's that paperclip needs
  #       file.original_filename = "#{@property&.property_name}.pdf"
  #       file.content_type = "application/pdf"
  #       landlord_report = @property.reports.new(report: file, landlord_id: @property&.landlord&.id, year: statement_year, month: month, report_type: 'landlord_statement', term_type: 'yearly')
  #       landlord_report.save
  #     end
  #   end
  # end

  ## rails landlords:send_booking_report_email
  desc 'Send Booking Report to lanlord'
  task send_booking_report_email: :environment do
    date = Date.today
    year = date.strftime('%y').to_i
    month = date.strftime('%m').to_i
    year = month < 9 ? "#{year - 1}/#{year}" :  "#{year}/#{year + 1}"
    @landlord = Landlord.where(send_report: 1)
    @landlord.all.each do |landlord|
      LandlordMailer.send_booking_report(year, landlord.id).deliver_now
      puts "Mail has been sent successfully #{landlord.landlord_name}"
    end
  end

end

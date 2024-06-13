## recurring the property_exenses
## rails properties:add_property_expenses
namespace :properties do
  desc 'Changed the booking status after done'
  task add_property_expenses: :environment do
    Property.includes(:property_expenses).joins(:property_expenses).uniq.each do |property|
      property_expenses = property.property_expenses.where(recurring: true, status: "Start").order(expense_date: :asc)
      property_expenses.each do |property_expense|
        date = property_expense.expense_date
        # get new expense date
        new_date = (property_expense.expense_date + 1.month)
        # get the new expense year
        year = new_date.strftime('%y').to_i
        month = new_date.strftime('%m').to_i
        new_year = month < 9 ? "#{year - 1}/#{year}" : "#{year}/#{year + 1}"
        # get current year
        c_year = Date.today.strftime('%y').to_i
        current_year  = Date.today.month < 9 ? ["#{c_year - 1}/#{c_year}", "#{c_year}/#{c_year + 1}"] : ["#{c_year}/#{c_year + 1}", "#{c_year + 1}/#{c_year + 2}"]
        p "========= check expense of current year #{current_year} ========="

        # make a new expense if expense date less than the date.today, no_of_months not equal to 0 and expense only for current year
        if(date < Date.today && property_expense.number_of_months != 0) && current_year.include?(property_expense.year)
          new_property_expense = property_expense.dup
          new_property_expense.number_of_months = (property_expense.number_of_months - 1) if (property_expense.number_of_months != nil && property_expense.number_of_months > 0)
          new_property_expense.expense_date = new_date
          new_property_expense.year = new_year
          new_property_expense.save
          p "==============new recurring property expense #{new_property_expense.inspect} has been created============="
          property_expense.update(status: 'Done')
          p "========old expense #{property_expense.inspect} has been updated========"
        end
      end
    end
  end

  ## Generate property monthly report
  ## rails properties:generate_property_report

  # desc 'Generate property monthly Report'
  # task generate_property_report: :environment do
  #   date = Date.today
  #   year = date.strftime('%y').to_i
  #   month = date.strftime('%m').to_i
  #   new_year = month < 9 ? "#{year - 1}/#{year}" : "#{year}/#{year + 1}"
  #   custom_report = CustomPropertyReport.find_by(month: month, year: new_year)
  #   if (custom_report && custom_report.start_date.to_date == Date.today) || custom_report.blank?
  #
  #     reports = Report.monthly.full_listing_monthly.where('DATE(created_at) between ? and ? and month = ?', Date.today.at_beginning_of_month, Date.today.at_end_of_month, Date.today.prev_month.month)
  #     unless reports.count > 0
  #       p "==== the property report is being start to generate  ====="
  #       report = PropertyReportPdf.new.render
  #       file = StringIO.new(report) #mimic a real upload file
  #       file.class.class_eval { attr_accessor :original_filename, :content_type } #add attr's that paperclip needs
  #       file.original_filename = "full_listing_monthly(#{Date.today.prev_month.strftime('%b_%Y')})_report.pdf"
  #       file.content_type = "application/pdf"
  #       date = Date.today
  #       year = date.strftime('%y').to_i
  #       month = date.strftime('%m').to_i
  #       report_year = month < 9 ? "#{year - 1}/#{year}" : "#{year}/#{year + 1}"
  #       property_report = Report.new(report: file, year: report_year, month: date.prev_month.month, term_type: 'monthly', report_type: 'full_listing_monthly')
  #       property_report.save
  #       p "==== property report #{property_report.inspect} ======="
  #       p "====== property report has been generated ======== "
  #     end
  #   else
  #     p "==== today report is not generated ====="
  #   end

  # end

  # rails properties:send_property_email
  # desc 'Send property report to accounts'
  # task send_property_email: :environment do
  #   date = Date.today
  #   year = date.strftime('%y').to_i
  #   month = date.strftime('%m').to_i
  #   new_year = month < 9 ? "#{year - 1}/#{year}" : "#{year}/#{year + 1}"
  #   custom_report = CustomPropertyReport.find_by(month: month, year: new_year)
  #   if (custom_report && custom_report.start_date.to_date == Date.today) || custom_report.blank?
  #     @property_report = Report.monthly.full_listing_monthly.find_by('DATE(created_at) = ? and mail_sent = ? and month = ?', Date.today, false, Date.today.prev_month.month)
  #     p " ========count #{@property_report.inspect}======"
  #     if @property_report.present?
  #       PropertyMailer.send_property_mail("james@cityletsplymouth.co.uk", @property_report.id).deliver_now
  #       PropertyMailer.send_property_mail("accounts@cityletsplymouth.co.uk", @property_report.id).deliver_now
  #       @property_report.update_columns({mail_sent: true, mail_sent_at: Time.now })
  #       puts 'Mail has been sent successfully'
  #     end
  #   else
  #     p "========== Mail is not sent by today =============="
  #   end
  # end

end

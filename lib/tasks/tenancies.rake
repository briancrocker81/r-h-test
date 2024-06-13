## rails tenancies:update_booking_status
namespace :tenancies do
  desc 'Generate PDF documents for tenancy and notify people via email'
  task generate_pdfs_and_notify: :environment do
    Tenancy.where('final_submission_at >= ?', 15.minutes.ago).each do |tenancy|
      if tenancy.save_pdf_files
        GuarantorMailer.send_dashboard_link(tenancy.guarantor.id).deliver_now if tenancy.guarantor.present? && tenancy.guarantor.guarantor_email.present?
        TenancyMailer.send_completed_form_to_tenant(tenancy.id).deliver_now
        TenancyMailer.notify_company_of_completed_form(tenancy.id).deliver_now
        Rails.logger.error "PDF Files Created for #{tenancy.id}"
      else
        Rails.logger.error "Unable to generate PDFs for tenancy #{tenancy.id}"
      end
    end
  end

  desc 'Destroys tenancies that have failed to book a room after 1 month'
  task destroy_failed_to_book: :environment do
    Tenancy.destroy_failed_to_book_tenancies_older_than(1.month)
  end

  desc 'Changed the booking status after done'
  task update_booking_status: :environment do
    tenancies = Tenancy.includes(:room).where("tenancy_end < ?", Date.today)
    if tenancies.count > 0
      tenancies.update_all(booking_status: 0)
      rooms = Room.where(id: tenancies.pluck(:room_id))
      rooms.update_all(availability: true)
    end
  end

  ## rails tenancies:update_tenancy_arrears
  desc 'Update tenancy payment due in arrears'
  task update_tenancy_arrears: :environment do
    payment_items = TenancyPaymentItem.where('due_date < ?', Date.today)
    payment_items.each do |payment_item|
      payment_item.arrears = (payment_item.amount_due.to_f - payment_item.amount_paid.to_f).round(2)
      p payment_item
      puts '=========================='
      payment_item.save
    end
  end

  ## rails tenancies:archiving_data_tenancies
  desc 'Archiving data tenancies'
  task archiving_data_tenancies: :environment do
    tenancies = Tenancy.where("tenancy_end < ?", Date.today)
    if tenancies.count > 0
      tenancies.update_all(archived: true)
    end
  end

  ## rails tenancies:expire_tenancies
  desc 'Expire tenancies'
  task expire_tenancies: :environment do
    tenancies = Tenancy.where("tenancy_end < ?", Date.today)
    if tenancies.count > 0
      tenancies.update_all(booking_status: 3)
    end
  end

  ## unchecked the tenancies dashboard profile
  desc "Uncheck the tenancies dashboard"
  task send_dashboard_link_to_tenancy: :environment do
    tenancies = Tenancy.where(year: "23/24")
    # tenancies.update_columns({final_submission: false, read_doc: false})
    tenancies.each do |tenancy|
      p tenancy
      TenancyMailer.send_dashboard_link(tenancy.id).deliver_now
      tenancy.update_column(:dashboard_link_mail_number_of_time, (tenancy.dashboard_link_mail_number_of_time.to_i + 1))
    end
  end
end

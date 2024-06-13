class TenancyMailer < ApplicationMailer
  include TenanciesHelper
  helper :tenancies
  # default from: 'accounts@cityletsplymouth.co.uk'

  def send_dashboard_link(tenancy_id)
    @tenancy = Tenancy.find tenancy_id
    mail(to: @tenancy.email, subject: "Dashboard link for #{@tenancy&.room&.property&.property_name}, room #{@tenancy&.room&.number}, #{@tenancy.tenant_name}")
  end

  def list_mailer(list_file)
    attachments['listings.pdf'] = File.read("#{Rails.root}/"+list_file)
    mail(to: "accounts@cityletsplymouth.co.uk", subject: "Listings file attachment")
    File.unlink(list_file)
  end

  ## mail to tenancy after complete tenancy dashboard
  def send_completed_form_to_tenant(tenancy_id)
    @tenancy = Tenancy.find_by(id: tenancy_id)
    attachments['tenancy_booking_form.pdf'] = TenancyBookingPdf.new(@tenancy).render
    attachments['tenancy_agreement.pdf'] = TenancyAgreementPdf.new(@tenancy).render
    attachments['tenancy_document.pdf'] = TenancyDocumentPdf.new(@tenancy).render
    mail to: @tenancy.email, subject: "Completed tenancy of #{@tenancy&.room&.property&.property_name}, room #{@tenancy&.room&.number}, #{@tenancy.tenant_name}"
  end

  def notify_company_of_completed_form(tenancy_id)
    @tenancy = Tenancy.find_by(id: tenancy_id)
    attachments['tenancy_booking_form.pdf'] = TenancyBookingPdf.new(@tenancy).render
    attachments['tenancy_agreement.pdf'] = TenancyAgreementPdf.new(@tenancy).render
    attachments['tenancy_document.pdf'] = TenancyDocumentPdf.new(@tenancy).render
    mail to: 'accounts@cityletsplymouth.co.uk', subject: "Completed tenancy of #{@tenancy&.room&.property&.property_name}, room #{@tenancy&.room&.number}, #{@tenancy.tenant_name}"
  end

  ## Mail for completed booking process
  def self.send_guarantor_completed_mail(guarantor_id)
    guarantor = Guarantor.find_by(id: guarantor_id)
    if guarantor
      tenancy = guarantor.tenancy
      subject = "Completed booking process of #{tenancy&.room&.property&.property_name}, room #{tenancy&.room&.number}, #{tenancy&.tenant_name}"
      send_mail_to_tenancy(tenancy, guarantor, subject).deliver_now
      send_mail_to_account(tenancy, guarantor, subject).deliver_now
    end
  end

  ## send completed mail to tenancy
  def send_mail_to_tenancy(tenancy, guarantor, subject)
    @tenancy = tenancy
    @guarantor = guarantor
    attachments['booking_form.pdf'] = TenancyBookingPdf.new(@tenancy).render
    attachments['tenancy_agreement.pdf'] = TenancyAgreementPdf.new(@tenancy).render
    attachments['signed_viewed_compliance_documents.pdf'] = TenancyDocumentPdf.new(@tenancy).render
    mail(to: @tenancy.email, subject: subject)
  end

  ## send complteted mail to system account
  def send_mail_to_account(tenancy, guarantor, subject)
    @tenancy = tenancy
    @guarantor = guarantor
    attachments['booking_form.pdf'] = TenancyBookingPdf.new(@tenancy).render
    attachments['tenancy_agreement.pdf'] = TenancyAgreementPdf.new(@tenancy).render
    attachments['signed_viewed_compliance_documents.pdf'] = TenancyDocumentPdf.new(@tenancy).render
    attachments['guarantor_agreement_form.pdf'] = GuarantorAgreementPdf.new(@guarantor, @tenancy).render
    mail(to: "accounts@cityletsplymouth.co.uk", subject: subject)
  end

  ## send tenancy payment items to tenant
  def send_payment_items(tenancy_id)
    @tenancy = Tenancy.find_by(id: tenancy_id)
    @tenancy_payment_items = get_tenancy_payment_items(@tenancy)
    mail(to: @tenancy.email, subject: "Payment schedule of #{@tenancy&.room&.property&.property_name}, room #{@tenancy&.room&.number}, #{@tenancy.tenant_name}")
  end

  ## send complete status
  def send_complete_status_mail(tenancy_id)
    @tenancy = Tenancy.find_by(id: tenancy_id)
    @guarantor = @tenancy.guarantor if @tenancy.guarantor
    mail(to: @tenancy.email, subject: 'Complete the tenancy')
  end
end

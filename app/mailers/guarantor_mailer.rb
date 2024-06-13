class GuarantorMailer < ApplicationMailer

  def send_dashboard_link(guarantor_id)
    @guarantor = Guarantor.find_by(id: guarantor_id)
    @tenancy = @guarantor.tenancy
    mail(to: @guarantor.guarantor_email, subject: "Guarantor agreement of #{@tenancy&.room&.property&.property_name}, room #{@tenancy&.room&.number}, #{@tenancy.tenant_name}")
  end

  def send_guarantor_completed_mail(guarantor_id)
    @guarantor = Guarantor.find_by(id: guarantor_id)
    @tenancy = @guarantor.tenancy
    attachments['booking_form.pdf'] = TenancyBookingPdf.new(@tenancy).render
    attachments['tenancy_agreement.pdf'] = TenancyAgreementPdf.new(@tenancy).render
    attachments['signed_viewed_compliance_documents.pdf'] = TenancyDocumentPdf.new(@tenancy).render
    attachments['guarantor_agreement_form.pdf'] = GuarantorAgreementPdf.new(@guarantor, @tenancy).render
    mail(to: @guarantor.guarantor_email, subject: "Guarantor completed of #{@tenancy&.room&.property&.property_name}, room #{@tenancy&.room&.number}, #{@tenancy.tenant_name}")
  end
end

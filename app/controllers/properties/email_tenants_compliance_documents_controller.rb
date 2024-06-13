module Properties
  class EmailTenantsComplianceDocumentsController < ApplicationController
    def create
      Property.find(params[:id]).email_tenants_compliance_documents!
    end
  end
end
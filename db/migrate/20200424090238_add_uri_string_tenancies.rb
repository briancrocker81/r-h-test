class AddUriStringTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :uri_string, :text
    add_column :tenancies, :form_submitted, :boolean, default: false
    add_column :tenancies, :signed_tenancy_agreement, :boolean, default: false
    add_column :tenancies, :read_doc, :boolean, default: false
  end
end

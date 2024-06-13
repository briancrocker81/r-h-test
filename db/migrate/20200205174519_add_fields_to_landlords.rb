class AddFieldsToLandlords < ActiveRecord::Migration[5.2]
  def change
    add_column :landlords, :date_last_contacted, :date
    add_column :landlords, :consent_for_marketing, :boolean
    add_column :landlords, :do_not_email, :boolean
    add_column :landlords, :do_not_phone, :boolean
    add_column :landlords, :do_not_post, :boolean
    add_column :landlords, :do_not_text, :boolean

    remove_column :landlords, :preferred_contact_method

  end
end

class RemoveMarketingFieldsFromLandlord < ActiveRecord::Migration[5.2]
  def change
    remove_column :landlords, :date_last_contacted
    remove_column :landlords, :consent_for_marketing
    remove_column :landlords, :do_not_email
    remove_column :landlords, :do_not_phone
    remove_column :landlords, :do_not_post
    remove_column :landlords, :do_not_text
  end
end

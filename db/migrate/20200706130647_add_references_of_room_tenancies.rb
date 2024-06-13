class AddReferencesOfRoomTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :dashboard_link_mail, :boolean, default: false
    add_column :tenancies, :dashboard_link_visited, :boolean, default: false
    add_column :tenancies, :dashboard_link_mail_at, :datetime
    add_column :tenancies, :dashboard_link_mail_number_of_time, :integer
  end
end

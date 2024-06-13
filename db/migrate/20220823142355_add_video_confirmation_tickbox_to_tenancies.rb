class AddVideoConfirmationTickboxToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :confirmed_video_viewed, :boolean
  end
end

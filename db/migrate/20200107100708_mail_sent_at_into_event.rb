class MailSentAtIntoEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :mail_sent_at, :datetime
  end
end

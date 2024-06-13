class MailSentToEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :mail_sent, :boolean, :default => false
  end
end

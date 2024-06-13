class CreateManageAutomationMails < ActiveRecord::Migration[5.2]
  def change
    create_table :manage_automation_mails do |t|
      t.string :mail_type
      t.text :mail_methods
      t.boolean :automation, default: true
      t.timestamps
    end
    add_index :manage_automation_mails, :mail_type
    add_index :manage_automation_mails, :automation
  end
end

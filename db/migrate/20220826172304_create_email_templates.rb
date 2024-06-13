class CreateEmailTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :email_templates do |t|
      t.string :template_name
      t.text :content
      t.timestamps
    end
  end
end

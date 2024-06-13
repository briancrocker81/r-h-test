class CreateSystemContentDataCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :system_content_data_categories do |t|
      t.string :category
      t.string :title

      t.timestamps
    end
  end
end

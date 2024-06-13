class CreateTenancyDocs < ActiveRecord::Migration[5.2]
  def change
    create_table :tenancy_docs do |t|
      t.references :tenancies, foreign_key: true
      t.string :document_type
      t.references :users, foreign_key: true

      t.timestamps
    end
  end
end

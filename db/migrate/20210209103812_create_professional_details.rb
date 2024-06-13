class CreateProfessionalDetails < ActiveRecord::Migration[5.2]
  def change
    create_table :professional_details do |t|
      t.string :working_at
      t.string :job_title
      t.integer :tenancy_id
      t.timestamps
    end
    add_index :professional_details, :tenancy_id
  end
end

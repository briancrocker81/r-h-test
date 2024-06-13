class AddNewFieldsToProfessionalDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :professional_details, :salary, :string
    add_column :professional_details, :salary_type, :integer
    add_column :professional_details, :employment_type, :integer
    add_column :professional_details, :receive_benefits, :boolean
    add_column :professional_details, :benefit_details, :text
  end
end

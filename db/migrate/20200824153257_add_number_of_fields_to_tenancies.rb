class AddNumberOfFieldsToTenancies < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :number_of_weeks, :integer
    add_column :tenancies, :number_of_months, :integer
  end
end

class AddRollbackColumnIntoTenancy < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :roll_into_next_year, :boolean, default: false
    add_index  :tenancies, :roll_into_next_year
  end
end

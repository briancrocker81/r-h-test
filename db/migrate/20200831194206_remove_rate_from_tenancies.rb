class RemoveRateFromTenancies < ActiveRecord::Migration[5.2]
  def change
    remove_column :tenancies, :rate
  end
end

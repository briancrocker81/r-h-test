class AddEpcRatingToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :epc_rating, :string, limit: 1
  end
end

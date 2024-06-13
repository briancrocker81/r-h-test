class AddFixedFeeFieldToLandlords < ActiveRecord::Migration[5.2]
  def change
    add_column :landlords, :fee, :string
  end
end

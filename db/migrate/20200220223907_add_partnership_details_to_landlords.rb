class AddPartnershipDetailsToLandlords < ActiveRecord::Migration[5.2]
  def change
    add_column :landlords, :partnership_format, :integer
    add_column :landlords, :rate, :string
  end
end

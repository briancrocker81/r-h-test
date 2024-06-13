class AddAlternateContactDetailsToLandlords < ActiveRecord::Migration[5.2]
  def change
    add_column :landlords, :alternate_name, :string
    add_column :landlords, :alternate_email, :string
  end
end

class AddLandlordReferenceToProperty < ActiveRecord::Migration[5.2]
  def change
    add_reference :properties, :landlord, foreign_key: true
  end
end

class AddFieldClientConfirmationToEvent < ActiveRecord::Migration[5.2]
  def change
  	add_column :events, :client_confirmation, :boolean, :default => false
  end
end

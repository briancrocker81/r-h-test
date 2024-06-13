class AddClientDetailsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :client_name, :string
    add_column :events, :client_contact_number, :string
  end
end

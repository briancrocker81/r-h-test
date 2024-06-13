class AddMoreDetailsToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :budget, :string 
    add_column :events, :budget_type, :integer, limit: 2
    add_column :events, :client_email, :string
    add_column :events, :client_required_bedrooms, :string
    add_column :events, :viewing_type, :integer, limit: 2
  end
end

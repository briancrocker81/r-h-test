class AddCyncToRoom < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :agent_ref, :string
    add_column :rooms, :rightmove_response, :json
  end
end

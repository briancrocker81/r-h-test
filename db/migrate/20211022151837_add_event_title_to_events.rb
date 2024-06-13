class AddEventTitleToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :event_title, :string
  end
end

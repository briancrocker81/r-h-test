class AlterEventFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :events, :title
    remove_column :events, :budget_type

    rename_column :events, :budget, :budget_per_week

    add_column :events, :budget_per_month, :string
  end
end

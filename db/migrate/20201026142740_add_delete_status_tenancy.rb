class AddDeleteStatusTenancy < ActiveRecord::Migration[5.2]
  def change
    add_column :tenancies, :archived, :boolean, default: false
  end
end

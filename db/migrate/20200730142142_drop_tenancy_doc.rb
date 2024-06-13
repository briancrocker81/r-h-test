class DropTenancyDoc < ActiveRecord::Migration[5.2]
  def change
    drop_table :tenancy_docs
  end
end

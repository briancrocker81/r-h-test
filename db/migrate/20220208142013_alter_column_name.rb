class AlterColumnName < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :properties, :on_market, :list_on_website
  end

  def self.down
    rename_column :properties, :list_on_website, :on_market
  end
end

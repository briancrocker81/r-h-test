class ChangeCouncilTaxReferenceForProperties < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :properties, :council_tax_reference, :council_tax_band
    change_column :properties, :council_tax_band, :string, limit: 1
  end

  def self.down
    rename_column :properties, :council_tax_band, :council_tax_reference
  end
end

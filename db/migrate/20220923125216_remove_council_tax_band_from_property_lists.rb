class RemoveCouncilTaxBandFromPropertyLists < ActiveRecord::Migration[5.2]
  def change
    remove_column :property_list_graduates, :council_tax_band
    remove_column :property_list_professionals, :council_tax_band
    remove_column :property_list_families, :council_tax_band
  end
end

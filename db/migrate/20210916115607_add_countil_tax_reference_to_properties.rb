class AddCountilTaxReferenceToProperties < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :council_tax_reference, :string
  end
end

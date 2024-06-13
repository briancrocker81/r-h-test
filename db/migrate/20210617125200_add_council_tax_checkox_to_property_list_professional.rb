class AddCouncilTaxCheckoxToPropertyListProfessional < ActiveRecord::Migration[5.2]
  def change
    add_column :property_list_professionals, :council_tax_included, :boolean
  end
end

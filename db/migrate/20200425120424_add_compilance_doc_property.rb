class AddCompilanceDocProperty < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :compliance_doc, :string
  end
end

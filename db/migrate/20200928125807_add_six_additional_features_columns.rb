class AddSixAdditionalFeaturesColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :property_list_students, :additional_features, :text
    remove_column :property_list_graduates, :additional_features, :text
    remove_column :property_list_professionals, :additional_features, :text
    remove_column :property_list_families, :additional_features, :text

    add_column :property_list_students, :additional_features_1, :string
    add_column :property_list_students, :additional_features_2, :string
    add_column :property_list_students, :additional_features_3, :string
    add_column :property_list_students, :additional_features_4, :string
    add_column :property_list_students, :additional_features_5, :string
    add_column :property_list_students, :additional_features_6, :string

    add_column :property_list_graduates, :additional_features_1, :string
    add_column :property_list_graduates, :additional_features_2, :string
    add_column :property_list_graduates, :additional_features_3, :string
    add_column :property_list_graduates, :additional_features_4, :string
    add_column :property_list_graduates, :additional_features_5, :string
    add_column :property_list_graduates, :additional_features_6, :string

    add_column :property_list_professionals, :additional_features_1, :string
    add_column :property_list_professionals, :additional_features_2, :string
    add_column :property_list_professionals, :additional_features_3, :string
    add_column :property_list_professionals, :additional_features_4, :string
    add_column :property_list_professionals, :additional_features_5, :string
    add_column :property_list_professionals, :additional_features_6, :string

    add_column :property_list_families, :additional_features_1, :string
    add_column :property_list_families, :additional_features_2, :string
    add_column :property_list_families, :additional_features_3, :string
    add_column :property_list_families, :additional_features_4, :string
    add_column :property_list_families, :additional_features_5, :string
    add_column :property_list_families, :additional_features_6, :string
  end
end

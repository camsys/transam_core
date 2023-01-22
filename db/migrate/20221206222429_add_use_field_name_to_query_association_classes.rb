class AddUseFieldNameToQueryAssociationClasses < ActiveRecord::Migration[5.2]
  def change
    add_column :query_association_classes, :use_field_name, :boolean, after: :id_field_name
  end
end

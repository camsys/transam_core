class AddQueryAssociationClassReferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :query_fields, :query_association_class, index: true
  end
end

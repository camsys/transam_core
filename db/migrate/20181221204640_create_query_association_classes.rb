class CreateQueryAssociationClasses < ActiveRecord::Migration[5.2]
  def change
    create_table :query_association_classes do |t|
      t.string :table_name
      t.string :display_field_name
      t.string :id_field_name, default: 'id'

      t.timestamps
    end
  end
end

class AddFieldsImages < ActiveRecord::Migration[5.2]
  def change
    add_reference :images, :base_imagable, polymorphic: true, after: :object_key
    add_column :images, :name, :string, after: :image
    add_column :images, :classification, :string, after: :image
    add_column :images, :exportable, :boolean, after: :description
  end
end

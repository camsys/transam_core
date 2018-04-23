class CreateSearchTypes < ActiveRecord::Migration
  def change
    create_table :search_types do |t|
      t.string :name
      t.string :class_name
      t.boolean :active
    end

    search_types = [
        {:active => 1, :name => 'Asset', :class_name => 'AssetSearcher'},
        {:active => 1, :name => 'Capital Plan', :class_name => 'CapitalProjectSearcher'}
    ]
    search_types.each do |type|
      SearchType.create!(type)
    end
  end
end

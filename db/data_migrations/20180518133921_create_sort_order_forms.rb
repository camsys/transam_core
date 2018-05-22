class CreateSortOrderForms < ActiveRecord::DataMigration
  def up
    Form.all.each_with_index{|f,idx| f.update!(sort_order: idx+1)}
  end
end
class RenameRatingColumnForConditionTypes < ActiveRecord::Migration[5.2]
  def change
    rename_column :condition_types, :rating, :rating_ceiling
  end
end

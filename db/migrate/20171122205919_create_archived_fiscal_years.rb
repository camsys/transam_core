class CreateArchivedFiscalYears < ActiveRecord::Migration
  def change
    create_table :archived_fiscal_years, id: false do |t|
      t.references :organization, index: true
      t.integer :fy_year
    end
  end
end

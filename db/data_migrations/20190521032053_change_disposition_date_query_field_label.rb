class ChangeDispositionDateQueryFieldLabel < ActiveRecord::DataMigration
  def up
    f =  QueryField.find_by_name 'disposition_date'
    if f
      f.update(label: 'Date of Disposition') 
    end
  end
end
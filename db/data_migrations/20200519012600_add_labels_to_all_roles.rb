class AddLabelsToAllRoles < ActiveRecord::DataMigration
  def up
    Role.all.each do |r|
      if r.label.nil?
        r.label = r.name.titleize
        r.save 
      end
    end
  end
end
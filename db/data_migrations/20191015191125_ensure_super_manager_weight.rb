class EnsureSuperManagerWeight < ActiveRecord::DataMigration
  def up
    Role.find_by(name: :super_manager)&.update(weight: 10)
  end
end
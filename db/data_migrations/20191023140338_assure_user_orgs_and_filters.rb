class AssureUserOrgsAndFilters < ActiveRecord::DataMigration
  def up
    service = Rails.application.config.new_user_service.constantize.new

    User.all.each do |usr|
      service.post_process usr, true
    end
  end
end
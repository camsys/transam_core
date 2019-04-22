module Abilities
  class Guest
    include CanCan::Ability

    def initialize(user)

      # view everything except the activity logs
      can :read, :all


      SystemConfig.transam_module_names.each do |mod|
        ability = "Abilities::Guest#{mod.classify}Ability".constantize.new(user) rescue nil

        self.merge ability if ability.present?
      end

    end
  end
end
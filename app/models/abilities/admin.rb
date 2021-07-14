module Abilities
  class Admin
    include CanCan::Ability

    def initialize(user)

      can :manage, :all

      SystemConfig.transam_module_names.each do |mod|
        ability = "Abilities::Admin#{mod.classify}Ability".constantize.new(user) rescue nil

        self.merge ability if ability.present?
      end

      cannot :assign, Role do |r|
        (!user.has_role?(:system_admin) && r.name == "system_admin") 
      end
    end
  end
end
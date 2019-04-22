module Abilities
  class Admin
    include CanCan::Ability

    def initialize(user)

      can :manage, :all

      SystemConfig.transam_module_names.each do |mod|
        ability = "Abilities::Admin#{mod.classify}Ability".constantize.new(user) rescue nil

        self.merge ability if ability.present?
      end
    end
  end
end
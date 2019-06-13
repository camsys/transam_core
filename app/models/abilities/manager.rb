module Abilities
  class Manager
    include CanCan::Ability

    def initialize(user)

      SystemConfig.transam_module_names.each do |mod|
        ability = "Abilities::Manager#{mod.classify}Ability".constantize.new(user) rescue nil

        self.merge ability if ability.present?
      end




    end
  end
end
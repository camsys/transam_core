module Abilities
  class SuperManagerCoreAbility
    include CanCan::Ability

    def initialize(user)

      ['Asset', 'AssetEvent'].each do |c|
        ability = "Abilities::SuperManager#{c}Ability".constantize.new(user)

        self.merge ability if ability.present?
      end

      can :assign, Role do |r|
        r.name != "admin"
      end

      # can manage SavedQuery
      can :manage, SavedQuery
    end
  end
end
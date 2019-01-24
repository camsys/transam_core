module Abilities
  class ManagerCoreAbility
    include CanCan::Ability

    def initialize(user)

      ['Asset', 'AssetEvent', 'Organization', 'Policy', 'Role', 'Upload', 'User', 'SavedQuery'].each do |c|
        ability = "Abilities::Manager#{c}Ability".constantize.new(user)

        self.merge ability if ability.present?
      end

    end
  end
end
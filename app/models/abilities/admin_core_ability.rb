module Abilities
  class AdminCoreAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      cannot [:update], Activity do |a|
        (a.system_activity == true)
      end
      cannot :destroy, Activity do |a|
        (a.system_activity == true)
      end
      cannot :create, Activity

    end
  end
end
module Abilities
  class GuestCoreAbility
    include CanCan::Ability

    def initialize(user)

      self.merge "Abilities::AuthorizedUserAbility".constantize.new(user)
      self.merge "Abilities::AuthorizedIssueAbility".constantize.new(user)

    end
  end
end
module Abilities
  class GuestCoreAbility
    include CanCan::Ability

    def initialize(user)

      self.merge Abilities::AuthorizedActivityLogAbility.new(user)
      self.merge Abilities::AuthorizedUserAbility.new(user)
      self.merge Abilities::AuthorizedIssueAbility.new(user)
      self.merge Abilities::AuthorizedSavedSearchAbility.new(user)
      self.merge Abilities::AuthorizedUserOrganizationFilterAbility.new(user)
    end
  end
end
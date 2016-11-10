module Abilities
  class AuthorizedIssueAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Issues
      #-------------------------------------------------------------------------
      # A user can manage issues if they created them
      can :manage, Issue do |issue|
        user.id == issue.created_by_id
      end

    end
  end
end
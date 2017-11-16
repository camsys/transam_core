module Abilities
  class AuthorizedTaskAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      #-------------------------------------------------------------------------
      # Tasks
      #-------------------------------------------------------------------------
      # Everyone can create a task
      can :create,  [Task]

      # Can manage them if you are the owner
      can :manage, Task do |t|
        t.user_id == user.id
      end
      # can update them if you are the recipient
      can [:update, :fire_workflow_event], Task do |t|
        t.assigned_to_user_id == user.id
      end

    end
  end
end
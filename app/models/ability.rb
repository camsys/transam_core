class Ability
  include CanCan::Ability

  # Define abilities for the passed in user here
  #
  # all actions must map to one of
  #   :read, 
  #   :create, 
  #   :update and 
  #   :destroy
  #
  def initialize(user)
    # Admins can do everything
    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :user
      can :manage, :all
    else
      can :read, :all
    end
  end
end

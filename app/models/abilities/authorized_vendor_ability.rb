module Abilities
  class AuthorizedVendorAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Vendors
      #-------------------------------------------------------------------------
      can :manage, Vendor do |v|
        v.organization_id == user.organization_id
      end

    end
  end
end
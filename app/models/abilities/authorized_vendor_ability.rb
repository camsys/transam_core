module Abilities
  class AuthorizedVendorAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      #-------------------------------------------------------------------------
      # Vendors
      #-------------------------------------------------------------------------
      can :manage, Vendor do |v|
        v.organization_id == user.organization_id
      end

    end
  end
end
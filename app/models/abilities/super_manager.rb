module Abilities
  class SuperManager
    include CanCan::Ability

    def initialize(user)

      SystemConfig.transam_module_names.each do |mod|
        ability = "Abilities::SuperManager#{mod.classify}Ability".constantize.new(user) rescue nil

        self.merge ability if ability.present?

      end

      self.merge(Abilities::Manager).new(user)

      # BPT super manager can add comments to funding sources
      can :create, Comment

      #-------------------------------------------------------------------------
      # Documents
      #-------------------------------------------------------------------------
      # documents for assets only if user can update asset
      can :create, Document do |d|
        if d.documentable_type == 'Asset'
          user.organization_ids.include? d.documentable.organization.id
        else
          true
        end
      end



    end
  end
end
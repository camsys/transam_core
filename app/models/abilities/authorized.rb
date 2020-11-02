module Abilities
  class Authorized
    include CanCan::Ability

    def initialize(user)

      # view everything except the activity logs
      can :read, :all

      #-------------------------------------------------------------------------
      # Comments
      #-------------------------------------------------------------------------
      # comments for assets only if user can update asset
      can :create, Comment do |c|
        if c.commentable_type == 'Asset'
          user.organization_ids.include? c.commentable.organization.id
        else
          true
        end
      end

      # Can manage them if you are the owner
      can [:update, :destroy], Comment do |c|
        c.created_by_id == user.id
      end
      #-------------------------------------------------------------------------
      # Documents
      #-------------------------------------------------------------------------
      # documents for assets only if user can update asset
      can :create, Document do |d|
        if d.documentable_type == Rails.application.config.asset_base_class_name
          user.organization_ids.include? d.documentable.organization.id
        else
          true
        end
      end

      # Can manage them if you are the owner
      can [:update, :destroy], Document do |d|
        d.created_by_id == user.id
      end
      #-------------------------------------------------------------------------
      # Images
      #-------------------------------------------------------------------------
      # images for assets only if user can update asset
      can :create, Image do |d|
        if d.imagable_type == 'Asset'
          user.organization_ids.include? d.imagable.organization.id
        else
          true
        end
      end

      # Can manage them if you are the owner
      can [:update, :destroy], Image do |d|
        d.created_by_id == user.id
      end

      SystemConfig.transam_module_names.each do |mod|
        ability = "Abilities::Authorized#{mod.classify}Ability".constantize.new(user) rescue nil

        self.merge ability if ability.present?
      end



    end
  end
end
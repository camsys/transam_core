module Abilities
  class ManagerUploadAbility
    include CanCan::Ability

    def initialize(user)

      #-------------------------------------------------------------------------
      # Uploads
      #-------------------------------------------------------------------------

      # bpt user can do bulk functions for anybody
      can [:update, :destroy], Upload do |u|
        [1,3,4,5].include? u.file_status_type_id
      end

    end
  end
end
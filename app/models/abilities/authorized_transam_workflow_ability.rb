module Abilities
  class AuthorizedTransamWorkflowAbility
    include CanCan::Ability

    def initialize(user, organization_ids=[])

      if organization_ids.empty?
        organization_ids = user.organization_ids
      end

      TransamWorkflow.implementors.each do |klass|
        klass.transam_workflow_transitions.each do |transition|
          if transition[:can].present?
            if transition[:can].is_a?(Hash)

              can transition[:event_name].to_sym, klass do |klass_instance|
                transition[:can].map{|k,v| klass_instance.state.to_s == k.to_s && klass_instance.send(v, user)}.any?
              end
            else
              can transition[:event_name].to_sym, klass do |klass_instance|
                klass_instance.send(transition[:can], user)
              end
            end



          else
            can transition[:event_name].to_sym, klass
          end
        end
      end

    end
  end
end
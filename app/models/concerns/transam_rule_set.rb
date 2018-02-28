#------------------------------------------------------------------------------
#
# TransamObjectKey
#
# Adds a unique object key to a model
#
#------------------------------------------------------------------------------
module TransamRuleSet
  
  extend ActiveSupport::Concern

  included do

  end


  def distribute
    # need to have a defined children has_many relationship
    # has to belong to several orgs
    if (respond_to? :parent_id) && (respond_to? :organizations)
      if self.where(parent_id: self.id).count == 0
        organizations.each do |org|
          new_child_rule = self.dup
          new_child_rule.object_key = nil
          new_child_rule.organization = org
          new_child_rule.save!
        end
      else
        puts " Error: can't distribute rule set thats already been distributed"
      end
    end
  end
end

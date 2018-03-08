class RuleSet < ActiveRecord::Base

  include TransamObjectKey

  # Callbacks
  after_initialize :set_defaults

  def to_s
    name
  end

  protected

  def set_defaults
    self.rule_set_aware = self.rule_set_aware.nil? ? true : self.rule_set_aware
  end

end

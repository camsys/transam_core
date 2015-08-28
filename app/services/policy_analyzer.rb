#------------------------------------------------------------------------------
#
# PolicyAnalyzer
#
# Wraps a policy for an asset and provides a shortcut for accessing the policy
# rules for the asset
#------------------------------------------------------------------------------
class PolicyAnalyzer

  attr_reader :asset
  attr_reader :policy
  attr_reader :asset_type_rule
  attr_reader :asset_subtype_rule

  # Define on self, since it's  a class method
  def method_missing(method_sym, *arguments)

    if method_sym.to_s =~ /^get_(.*)$/
      actual_method_sym = method_sym.to_s[4..-1].to_sym
      if policy.respond_to? actual_method_sym
        method_object = asset_type_rule.method(actual_method_sym)
        method_object.call(*arguments)
      elsif asset_type_rule.respond_to? actual_method_sym
        method_object = asset_type_rule.method(actual_method_sym)
        method_object.call(*arguments)
      elsif asset_subtype_rule.respond_to? actual_method_sym
        method_object = asset_subtype_rule.method(actual_method_sym)
        method_object.call(*arguments)
      end
    else
      super
    end
  end

  # Delegate to the type and subtype rules
  def respond_to?(method_sym, include_private = false)
    if method_sym.to_s =~ /^get_(.*)$/
      actual_method_sym = method_sym.to_s[4..-1].to_sym
      if policy.respond_to? actual_method_sym or asset_type_rule.respond_to? actual_method_sym or asset_subtype_rule .respond_to? actual_method_sym
        true
      else
        super
      end
    else
      super
    end
  end

  def initialize(asset, policy)
    @asset = asset
    @policy = policy
    if @policy.present? and @asset.present?
      @asset_type_rule = @policy.policy_asset_type_rules.find_by(:asset_type_id => asset.asset_type_id)
      @asset_subtype_rule = @policy.policy_asset_subtype_rules.find_by(:asset_subtype_id => asset.asset_subtype_id)
    end
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

end

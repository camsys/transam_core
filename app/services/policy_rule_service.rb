#------------------------------------------------------------------------------
#
# PolicyRuleService
#
# Attempts to find the policy rule that best matches an asset
#
# The service returns a single policy rule or nil if no matching policy rule is 
# found. This is a naieve version that simply returns the first match based on the 
# asset subtype. Applicaitons should override this implementation with more
# specific logic
#
#------------------------------------------------------------------------------
class PolicyRuleService
    
  #------------------------------------------------------------------------------
  #
  # Match
  #
  # Single entry point. User passes in a policy and an asset. 
  #
  #------------------------------------------------------------------------------  
  def match(policy, asset)

    if policy.nil?
      Rails.logger.info "policy cannot be nil."
      return
    end
    if asset.nil?
      Rails.logger.info "asset cannot be nil."
      return
    end
    
    p = policy
    # make sure the asset is typed
    a = asset.is_typed? ? asset : Asset.get_typed_asset(asset)
    
    # Check the rules for this policy and its parents
    p = policy
    while p
      rule = evaluate(p, a)
      if rule
        break
      else
        # Check the policies parent if it has one
        p = p.parent
      end
    end
    rule
  end

  #------------------------------------------------------------------------------
  #
  # Protected Methods
  #
  #------------------------------------------------------------------------------
  protected
  
  # Perform the actual logic for matching a policy item to an asset.
  def evaluate(policy, asset)   
    policy.policy_items.where('asset_subtype_id = ?', asset.asset_subtype_id).first
  end
  
  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private
  
end
class RuleSetsController < OrganizationAwareController
  add_breadcrumb "Home", :root_path
  add_breadcrumb "Policies", :rule_sets_path

  before_action :set_rule_set, only: [:show]

  # GET /rule_sets
  def index
    @rule_sets = RuleSet.all
  end

  # GET /rule_sets/1
  def show

    if @rule_set.rule_set_aware
      path = eval("rule_set_#{@rule_set.class_name.underscore.pluralize}_path('#{@rule_set.object_key}')")
    else
      path = eval("#{@rule_set.class_name.underscore.pluralize}_path")
    end

    redirect_to path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule_set
      @rule_set = RuleSet.find_by(object_key: params[:id])
    end

end

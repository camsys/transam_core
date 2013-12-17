class DashboardsController < OrganizationAwareController
        
  def index
    
    @page_title = 'Dashboard'
    
    # Select messages for this user or ones that are for the agency as a whole
    @messages = Message.where("organization_id = ? AND thread_message_id IS NULL AND (to_user_id IS NULL OR to_user_id = ?)", @organization.id, current_user.id).order("created_at DESC")
    # Select tasks for this user or ones that are for the agency as a whole
    @tasks = Task.where("for_organization_id = ? AND completed_on IS NULL AND (assigned_to_user_id IS NULL OR assigned_to_user_id = ?)", @organization.id, current_user.id).order("complete_by")
        
    @summary_counts_by_type = get_summary_counts_by_type(@organization)    
    @summary_counts_by_condition = get_summary_counts_by_condition(@organization)
    
  end

  
  # renders a dashboard detail page. Actual details depends on the id parameter passed
  # from the view
  def show

    @type = params[:id].to_i
    if @type == 1
      @page_title = "Managed Assets"
      @chart_data = get_summary_counts_by_type(@organization)
    elsif @type == 2
      @page_title = "Asset Condition"
      @chart_data = get_summary_counts_by_condition(@organization)
    elsif @type == 3
      @page_title = "Age By Asset Type"
      @chart_data = get_summary_counts_by_age(@organization)          
    elsif @type == 4
      @page_title = "Backlog"
      @chart_data = get_backlog(@organization)          
    elsif @type == 5
      @page_title = "Capital Needs By Asset Type"
      @chart_data = get_replacement_needs_by_year(@organization)          
    end
    
  end

private

  def get_summary_counts_by_type(organization)

    a = [] 
    
    labels = ['Asset Type', 'Count']
    
    AssetType.all.each do |x| 
      count = organization.assets.where("asset_type_id = ?", x.id).count
      a << [x.name, count] unless count == 0
    end   

    return {:labels => labels, :data => a}
     
  end

  def get_summary_counts_by_condition(organization)

    a = [] 
    labels = ['Condition', 'Count']

    ConditionType.all.each do |x|
      count = organization.assets.where("last_reported_condition_type_id = ?", x.id).count
      a << [x.name, count]
    end
        
    return {:labels => labels, :data => a}
     
  end

  def get_summary_counts_by_age(organization)

    a = []
    labels = ['Age (Years)']

    AssetType.all.each do |type| 
      labels << type.name
    end
        
    (1..(MAX_YEARS_FUTURE - 1)).each do |year|
      counts = []
      counts << year.to_s
      to_date = (year-1).year.ago
      from_date = year.year.ago
      AssetType.all.each do |type| 
        counts << Asset.where("organization_id = ? AND asset_type_id = ? AND install_date BETWEEN ? AND ?", organization.id, type.id, from_date, to_date).count
      end
      a << counts
    end

    # get the bucket for MAX_YEARS+ years old
    year = MAX_YEARS_FUTURE
    counts = []
    counts << year.to_s
    to_date = 100.year.ago
    from_date = year.year.ago
    AssetType.all.each do |type| 
      counts << Asset.where("organization_id = ? AND asset_type_id = ? AND install_date BETWEEN ? AND ?", organization.id, type.id, from_date, to_date).count
    end
    a << counts
        
    return {:labels => labels, :data => a}
     
  end
  
end

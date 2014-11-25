class AssetGroupsController < OrganizationAwareController
  
  before_action :set_asset_group, :only => [:show, :edit, :update, :destroy]

  add_breadcrumb "Home", :root_path

  # GET /asset_groups
  def index
    
    add_breadcrumb 'Asset Groups', asset_groups_path

    @asset_groups = @organization.asset_groups

  end

  # GET /asset_groups/1
  def show

    add_breadcrumb 'Asset Groups', asset_groups_path
    add_breadcrumb @asset_group
    
    rep = AssetSubtypeReport.new
    @data = rep.get_data_from_collection(@asset_group.assets)
    @total_assets = @asset_group.assets.count
    
  end

  # GET /asset_groups/new
  def new

    add_breadcrumb 'Asset Groups', asset_groups_path
    add_breadcrumb 'New'
    @asset_group = AssetGroup.new
    
  end

  # GET /asset_groups/1/edit
  def edit

    add_breadcrumb 'Asset Groups', asset_groups_path
    add_breadcrumb @asset_group, asset_group_path(@asset_group)
    add_breadcrumb 'Update'
  
  end

  # POST /asset_groups
  def create
    @asset_group = AssetGroup.new(form_params)
    @asset_group.organization = @organization
    
    add_breadcrumb 'Asset Groups', asset_groups_path
    add_breadcrumb 'New'

    if @asset_group.save
      redirect_to asset_group_path(@asset_group)
    else
      render :new
    end
  end

  # PATCH/PUT /issues/1
  def update

    add_breadcrumb 'Asset Groups', asset_groups_path
    add_breadcrumb @asset_group, asset_group_path(@asset_group)
    add_breadcrumb 'Update'

    if @asset_group.update(form_params)
      redirect_to @asset_group, notice: 'Asset group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /issues/1
  def destroy
    @asset_group.destroy
    redirect_to asset_groups_url, notice: 'Asset Group was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset_group
      @asset_group = AssetGroup.find_by_object_key(params[:id]) unless params[:id].nil?
    end

    # Only allow a trusted parameter "white list" through.
    def form_params
      params.require(:asset_group).permit(AssetGroup.allowable_params)
    end
end

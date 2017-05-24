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

    # See if the user added a flag to load from a search results
    if params[:from_search] == "1"
      @use_cached_assets = "1"
    end

  end

  # GET /asset_groups/1/edit
  def edit

    add_breadcrumb 'Asset Groups', asset_groups_path
    add_breadcrumb @asset_group, asset_group_path(@asset_group)
    add_breadcrumb 'Update'

  end

  # POST /asset_groups
  def create

    add_breadcrumb 'Asset Groups', asset_groups_path
    add_breadcrumb 'New'

    @asset_group = AssetGroup.new(form_params)
    @asset_group.active = true
    @asset_group.organization = @organization
    @asset_group.active = true

    if @asset_group.save

      # See if the user is creating the group from a set of cached assets
      if params[:use_cached_assets] == "1"
        # Populate the asset group from the cached results
        cache_key = AssetSearcher.new.cache_variable_name
        assets = Asset.where(object_key: get_cached_objects(cache_key))
        assets.each do |asset|
          a = Asset.get_typed_asset(asset)
          @asset_group.assets << a
        end
        # clear out the cached items once they're in a group
        clear_cached_objects(cache_key)
        notify_user(:notice, "Asset group #{@asset_group} was successfully created and #{@asset_group.assets.count} assets were added.")
      else
        notify_user(:notice, "Asset group #{@asset_group} was successfully created.")
      end

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
      notify_user(:notice, "Asset group #{@asset_group} was successfully updated.")
      redirect_to @asset_group
    else
      render :edit
    end
  end

  # DELETE /issues/1
  def destroy

    name = @asset_group.name
    @asset_group.destroy

    notify_user(:notice, "Asset group #{name} was successfully removed.")
    redirect_to asset_groups_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_asset_group
      @asset_group = AssetGroup.find_by_object_key(params[:id]) unless params[:id].nil?
      if @asset_group.nil?
        redirect_to '/404'
        return
      end
    end

    # Only allow a trusted parameter "white list" through.
    def form_params
      params.require(:asset_group).permit(AssetGroup.allowable_params)
    end
end

class ManufacturersController < OrganizationAwareController

  add_breadcrumb "Home", :root_path

  def index

    add_breadcrumb "Manufacturers", manufacturers_path

    @manufacturers = Manufacturer.joins(:assets).where(assets: {organization_id: @organization_list}).distinct

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @manufacturers }
    end
  end

  protected

  private

end

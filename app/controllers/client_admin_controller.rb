class ClientAdminController < OrganizationAwareController
  add_breadcrumb 'Home', :root_path

  # GET /client_admin
  def index
    add_breadcrumb 'Client Admin Interface', client_admin_path
  end

end

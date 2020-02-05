class Api::V1::OrganizationsController < Api::ApiController
  # Given organization_id, look up org profile
  # GET /organizations/{id}
  def show
    get_organization(params[:id])

    unless @organization
      @status = :fail
      @data = {id: "Organization #{params[:id]} not found."}
      render status: :not_found, json: json_response(:fail, data: @data)
    end
  end

  def index
    orgs = current_user.viewable_organizations.map{ |o| {id: o.id, name: o.name}}
    render status: 200, json: orgs 
  end

  private

  def get_organization(org_id)
    org_id = org_id.to_i unless org_id.blank?
    
    if @user.viewable_organization_ids.include?(org_id)
      @organization = Organization.find_by_id(org_id)
    end
  end
end

class UserLoginReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end

  def get_data(organization_id_list, params)


    {data: User.joins(:organization).where("organization_id IN (?) AND last_sign_in_at IS NOT NULL", organization_id_list).order(:organization_id, :first_name, :last_name).pluck('organizations.short_name', :first_name, :last_name, :sign_in_count, :last_sign_in_at, :locked_at)}

  end

end

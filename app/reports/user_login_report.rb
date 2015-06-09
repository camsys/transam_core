class UserLoginReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end

  def get_data(organization_id_list, params)

    User.where("organization_id IN (?) AND last_sign_in_at IS NOT NULL", organization_id_list).order(:organization_id, :first_name, :last_name)

  end

end

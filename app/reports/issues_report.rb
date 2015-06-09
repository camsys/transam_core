class IssuesReport < AbstractReport

  def initialize(attributes = {})
    super(attributes)
  end

  def get_data(organization_id_list, params)

    Issue.all.order(:created_at, :issue_type_id)

  end

end

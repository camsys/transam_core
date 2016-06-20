class IssuesController < OrganizationAwareController

  before_action :set_issue, only: [:show, :edit, :update, :destroy, :success, :review]

  add_breadcrumb "Home", :root_path

  # GET /issues
  def index
    @issues = Issue.all
  end

  # GET /issues/1
  def show
    add_breadcrumb "Viewing Issue"
  end

  # GET /issues/1/review
  def review
    add_breadcrumb "Viewing Issue"
  end

  # GET /issues/1
  def success
    add_breadcrumb "Success"
  end

  # GET /issues/new
  def new
    add_breadcrumb "Report an issue"

    @issue = Issue.new
  end

  # GET /issues/1/edit
  def edit
    add_breadcrumb "Resolve an issue"

    if can? :manage_issue, @issue
      @resolving_issue = true
    else
      redirect_to review_issue_path(@issue)
    end
  end

  # POST /issues
  def create
    @issue = Issue.new(issue_params)
    @issue.creator = current_user

    add_breadcrumb "Report an issue"

    if @issue.save
      redirect_to success_issue_path(@issue)
    else
      render :new
    end
  end

  # PATCH/PUT /issues/1
  def update
    if @issue.update(issue_params)
      redirect_to success_issue_path(@issue)
    else
      @resolving_issue = true
      render :edit
    end
  end

  # DELETE /issues/1
  def destroy
    @issue.destroy
    redirect_to issues_url, notice: 'Issue was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      @issue = Issue.find_by_object_key(params[:id]) unless params[:id].nil?
      if @issue.nil?
        redirect_to '/404'
        return
      end
    end

    # Only allow a trusted parameter "white list" through.
    def issue_params
      params.require(:issue).permit(Issue.allowable_params)
    end
end

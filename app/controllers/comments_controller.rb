class CommentsController < OrganizationAwareController
  before_action :set_comment, :only => [:edit, :update, :destroy]

  # GET /comments
  # GET /comments.json
  def index
       
    @commentable = find_commentable
    @comments = @commentable.comments
  
    @page_title = "#{@commentable.project_number}: Comments"

  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit

    @commentable = @comment.commentable
    @page_title = "#{@commentable.project_number}: Edit comment"

  end

  # POST /comments
  # POST /comments.json
  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(comment_params)
    @comment.creator = current_user
    
    respond_to do |format|
      if @comment.save
        notify_user(:notice, 'Comment was successfully created.')
        url = "#{@commentable.class.name.underscore}_url('#{@commentable.object_key}')"   
        format.html { redirect_to eval(url) }
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.html { render action: 'new' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update

    @commentable = @comment.commentable

    respond_to do |format|
      if @comment.update(comment_params)
        notify_user(:notice, 'Comment was successfully updated.')   
        url = "#{@commentable.class.name.underscore}_url('#{@commentable.object_key}')"   
        format.html { redirect_to eval(url) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy

    @commentable = @comment.commentable    
    @comment.destroy
    
    notify_user(:notice, 'Comment was successfully removed.')   
    respond_to do |format|
      url = "#{@commentable.class.name.underscore}_url('#{@commentable.object_key}')"   
      format.html { redirect_to eval(url) }
      format.json { head :no_content }
    end
  end

  private

  # Get the class and object key of the commentable object we are operating on
  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find_by_object_key(value)
      end
    end
    
    nil
  end
    
  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find_by_object_key(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(comment_allowable_params)
  end

end

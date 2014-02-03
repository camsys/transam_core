class NotesController < AssetAwareController
    
  before_action :set_note,          :only => [:show, :edit, :update, :destroy, :download]  
  before_filter :check_for_cancel,  :only => [:create, :update]

  # always use generic untyped assets for this controller
  RENDER_TYPED_ASSETS = false

  SESSION_VIEW_TYPE_VAR = 'asset_notes_subnav_view_type'

  # always render untyped assets for this controller
  def render_typed_assets
    RENDER_TYPED_ASSETS
  end

  def index

    @notes = @asset.notes.order('created_at')
    @page_title = 'Notes'
    
     # remember the view type
    @view_type = get_view_type(SESSION_VIEW_TYPE_VAR)
   
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @notes}
    end

  end
  
  def show

    @page_title = "Note"
      
    if @note.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_notes_url(@asset))
      return            
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @attachment}
    end

  end

  def create      

    @note = Note.new(form_params)
    @note.asset = @asset
    @note.creator = current_user
    
    respond_to do |format|
      if @note.save        
        notify_user(:notice, "Note was successfully saved.")
        format.html { redirect_to inventory_notes_url(@asset) }
        format.json { render :json => @note, :status => :created, :location => @note }
      else
        format.html { render :action => "new" }
        format.json { render :json => @note.errors, :status => :unprocessable_entity }
      end
    end
    
  end

  def edit

    @page_title = "Update Note"

    if @note.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_notes_url(@asset))
      return            
    end
    @page_title = @note.created_at.to_s
  end
  
  def update

    if @note.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_notes_url(@asset))
      return            
    end

    respond_to do |format|
      if @note.update_attributes(form_params)
        notify_user(:notice, "Note was successfully updated.")
        format.html { redirect_to inventory_note_url(@asset, @note)}
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @note.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def new

    @page_title = "New Note"
    @note = Note.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @note }
    end
    
  end

  def destroy

    if @note.nil?
      notify_user(:alert, 'Record not found!')
      redirect_to(inventory_notes_url(@asset))
      return      
    end

    @note.destroy

    notify_user(:notice, 'Note was successfully removed.')

    respond_to do |format|
      format.html { redirect_to(inventory_notes_url(@asset)) } 
      format.json { head :no_content }
    end
  end

  #------------------------------------------------------------------------------
  #
  # Private Methods
  #
  #------------------------------------------------------------------------------
  private

  def set_note
    @note = @asset.notes.find_by_object_key(params[:id]) unless params[:id].nil?
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def form_params
    params.require(:note).permit(note_allowable_params)
  end
  
  def check_for_cancel
    unless params[:cancel].blank?
      get_asset
      if @asset.nil?
        notify_user(:alert, 'Record not found!')
        redirect_to(inventory_url)
        return      
      end
      redirect_to inventory_url(@asset)
    end
  end
    
end

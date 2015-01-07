class FullTextSearchIndicesController < ApplicationController
  before_action :set_full_text_search_index, only: [:show, :edit, :update, :destroy]

  # GET /full_text_search_indices
  def index
    @full_text_search_indices = FullTextSearchIndex.all
  end

  # GET /full_text_search_indices/1
  def show
  end

  # GET /full_text_search_indices/new
  def new
    @full_text_search_index = FullTextSearchIndex.new
  end

  # GET /full_text_search_indices/1/edit
  def edit
  end

  # POST /full_text_search_indices
  def create
    @full_text_search_index = FullTextSearchIndex.new(full_text_search_index_params)

    if @full_text_search_index.save
      redirect_to @full_text_search_index, notice: 'Full text search index was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /full_text_search_indices/1
  def update
    if @full_text_search_index.update(full_text_search_index_params)
      redirect_to @full_text_search_index, notice: 'Full text search index was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /full_text_search_indices/1
  def destroy
    @full_text_search_index.destroy
    redirect_to full_text_search_indices_url, notice: 'Full text search index was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_full_text_search_index
      @full_text_search_index = FullTextSearchIndex.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def full_text_search_index_params
      params.require(:full_text_search_index).permit(:object_key, :search_text)
    end
end

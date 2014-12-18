class SearchController < ApplicationController

	def search
	  if params[:q].nil?
	    @articles = []
	  else
	    @articles = Article.search params[:q]
	  end
	end
	
end

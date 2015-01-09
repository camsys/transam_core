#full_text_searchable.rb
#------------------------------------------------------------------------------
#
# Full Text Searchable
#
# Mixin that adds a fiscal year methods to a class
#
#------------------------------------------------------------------------------
module KeywordSearchable

  def write_to_keyword_search_index

    text_blob = ""
    separator = " "
    searchable_fields.each { |searchable_field|
      text_blob += self.send(searchable_field).to_s
      text_blob += separator
    }

    kwsi = KeywordSearchIndex.find_or_create_by(object_key: object_key) do |keyword_search_index|
  		keyword_search_index.search_text = text_blob
      keyword_search_index.object_class = self.class.name
	  end

    kwsi.search_text = text_blob
    kwsi.object_class = self.class.name

    kwsi.save!
    
  end

end
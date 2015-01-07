#full_text_searchable.rb
#------------------------------------------------------------------------------
#
# Full Text Searchable
#
# Mixin that adds a fiscal year methods to a class
#
#------------------------------------------------------------------------------
module FullTextSearchable

  def write_to_full_text_search_index

    text_blob = ""
    separator = " "
    searchable_fields.each { |searchable_field|
      text_blob += self.send(searchable_field).to_s
      text_blob += separator
    }

    FullTextSearchIndex.find_or_create_by(object_key: object_key) do |full_text_search_index|
  		full_text_search_index.search_text = text_blob
	  end
    
  end

end
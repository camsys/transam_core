require 'elasticsearch/model'
module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    def self.search(query)
    	search(query)
    end
  end
end
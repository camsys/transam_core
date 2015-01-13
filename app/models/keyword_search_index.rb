class KeywordSearchIndex < ActiveRecord::Base

	validates     :object_key,	:presence => true
  validates     :object_class,	:presence => true
  validates     :search_text,	:presence => true

	def to_s
		self.name.to_s
	end

end

class KeywordSearchIndex < ActiveRecord::Base

	def to_s
		self.name.to_s
	end

end

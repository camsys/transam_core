#------------------------------------------------------------------------------
#
# UniqueKey
#
# Mixin that adds a unique key to a model
#
#------------------------------------------------------------------------------
module UniqueKey

  # Generates a unique 12 character key for each workorder. Key is based on
  # nano seconds since the epoch then converted into a base 24 number 
  def generate_unique_key(column)
    begin
      self[column] = (Time.now.to_f * 10000000).to_i.to_s(24).upcase
    end #while self.exists?(column => self[column])
  end

end

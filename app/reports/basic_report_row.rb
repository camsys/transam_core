class BasicReportRow
  
  attr_accessor  :key, :count, :replacement_cost, :id_list
  
  def initialize(key)
    self.key = key
    self.count = 0
    self.replacement_cost = 0
    self.id_list = []
  end
  
  def add(asset)
    self.count += 1
    self.replacement_cost += asset.replacement_cost
    self.id_list << asset.asset_key
  end
  
end

class BasicReportRow

  attr_accessor  :key, :count, :replacement_cost, :id_list, :cost_recovery

  def initialize(key)
    self.key = key
    self.count = 0
    self.replacement_cost = 0
    self.cost_recovery = 0
    self.id_list = []
  end

  def add(asset)
    self.count += 1
    self.replacement_cost += asset.estimated_replacement_cost unless asset.estimated_replacement_cost.nil?
    self.id_list << asset.object_key
  end

end

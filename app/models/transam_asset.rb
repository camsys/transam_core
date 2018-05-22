class TransamAsset < ApplicationRecord

  include TransamObjectKey

  actable as: :transam_assetible

  belongs_to  :organization
  belongs_to  :asset_subtype
  belongs_to  :manufacturer
  belongs_to  :vendor
  belongs_to  :operator
  belongs_to  :title_owner
  belongs_to  :lienholder

  def self.specific
    klass = self
    assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
    assoc_arr = Hash.new
    assoc_arr[assoc] = nil
    t = klass.distinct.where.not(assoc_arr).pluck(assoc)

    while t.count == 1
      id_col = assoc[0..-6] + '_id'
      klass = t.first.constantize.where(id: klass.pluck(id_col))
      assoc = klass.column_names.select{|col| col.end_with? 'ible_type'}.first
      assoc_arr = Hash.new
      assoc_arr[assoc] = nil
      t = klass.distinct.where.not(assoc_arr).pluck(assoc)
    end

    return klass

  end

end

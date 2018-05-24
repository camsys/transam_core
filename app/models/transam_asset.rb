class TransamAsset < ApplicationRecord

  include TransamObjectKey

  actable as: :transam_assetible

  belongs_to  :organization
  belongs_to  :asset_subtype
  belongs_to  :manufacturer
  belongs_to  :vendor
  belongs_to  :operator
  belongs_to  :title_ownership_organization, :class_name => 'Organization'
  belongs_to  :lienholder

  def self.very_specific
    klass = self.all
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

  def very_specific
    a = self.specific

    while a.try(:specific) != a
      a = a.specific
    end

    return a
  end

end

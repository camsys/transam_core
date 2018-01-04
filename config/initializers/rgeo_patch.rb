# the following initializer is to deal with this issue with the schema dumper
# https://github.com/rgeo/rgeo-activerecord/issues/23

module RGeo
  module ActiveRecord
    RGeo::ActiveRecord.send(:remove_const, :SpatialIndexDefinition)
    class SpatialIndexDefinition < Struct.new(:table, :name, :unique, :columns, :lengths, :orders, :where, :spatial, :using, :type)
    end
  end
end
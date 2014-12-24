require 'elasticsearch/model'
class Customer < ActiveRecord::Base

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  #associations
  belongs_to  :license_type
  has_one     :license_holder, -> { where('license_holder = true')}, :class_name => 'Organization'
  has_many    :organizations
  has_many    :users
    
  #attr_accessible :license_type_id, :active
    
  # default scope
  default_scope { where(:active => true) }

  def to_s
    name
  end
  
end
      
Customer.import  # for auto sync model with elastic search
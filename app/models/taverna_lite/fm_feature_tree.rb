module TavernaLite
  class FmFeatureTree < ActiveRecord::Base
    attr_accessible :cardinality_lower_bound, :cardinality_upper_bound, :feature_model_id, :feature_type_id, :name, :parent_node_id
  end
end

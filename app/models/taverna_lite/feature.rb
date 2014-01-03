module TavernaLite
  class Feature < ActiveRecord::Base
    attr_accessible :cardinality_lower_bound, :cardinality_upper_bound,
    :component_id, :feature_model_id, :feature_type_id, :name, :parent_node_id
    def parent
      Feature.find(parent_node_id)
    end
  end
end

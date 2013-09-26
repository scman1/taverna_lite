module TavernaLite
  class AlternativeComponent < ActiveRecord::Base
    attr_accessible :alternative_id, :component_id, :note
  end
end

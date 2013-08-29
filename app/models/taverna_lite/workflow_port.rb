module TavernaLite
  class WorkflowPort < ActiveRecord::Base
    attr_accessible :description, :display_description, :display_name, :name, :order, :port_type_id, :workflow_id
  end
end

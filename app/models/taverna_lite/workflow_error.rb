module TavernaLite
  class WorkflowError < ActiveRecord::Base
    attr_accessible :error_code, :message, :name, :pattern, :port_count, :run_count, :workflow_id
  end
end

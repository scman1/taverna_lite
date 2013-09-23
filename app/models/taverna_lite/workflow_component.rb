module TavernaLite
  class WorkflowComponent < ActiveRecord::Base
    attr_accessible :family, :license_id, :version, :workflow_id
  end
end

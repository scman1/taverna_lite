module TavernaLite
  class WorkflowComponent < ActiveRecord::Base
    attr_accessible :family, :license_id, :name, :registry, :version, :workflow_id
    belongs_to :workflow, class_name: TavernaLite.workflow_class
  end
end

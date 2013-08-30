module TavernaLite
  class WorkflowError < ActiveRecord::Base
    attr_accessible :error_code, :message, :name, :pattern, :port_count, 
      :run_count, :workflow_id
    # Each error will be mapped to a workflow in the main application
    belongs_to :workflow, class_name: TavernaLite.workflow_class
    # Before saving the error, set the workflow to which it has been associated
    before_save :set_workflow
    private
    def set_workflow
      self.workflow = TavernaLite.workflow_class.find(self.workflow_id)
    end 
  end
end

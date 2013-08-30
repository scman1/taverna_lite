module TavernaLite
  class WorkflowPort < ActiveRecord::Base
    attr_accessible :description, :display_description, :display_name, :name, 
      :order, :port_type_id, :workflow_id
    # Each port will be mapped to a workflow in the main application
    belongs_to :workflow, class_name: TavernaLite.workflow_class 
    # Before saving the port, set the workflow to which it has been associated
    before_save :set_workflow
    private
    def set_workflow
      self.workflow = TavernaLite.workflow_class.find(self.workflow_id)
    end 
  end
end

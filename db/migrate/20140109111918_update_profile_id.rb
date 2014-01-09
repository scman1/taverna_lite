class UpdateWorkflowProfileId < ActiveRecord::Migration
  def up
    TavernaLite::WorkflowPort.all.each {|pt|
      unless TavernaLite::WorkflowProfile.where(:workflow_id => pt.workflow_id).blank?
        pt.workflow_profile_id = TavernaLite::WorkflowProfile.find_by_workflow_id(pt.workflow_id).id
        pt.save
      end
    }
  end
  def down
    TavernaLite::WorkflowPort.all.each {|pt|
      pt.workflow_id = TavernaLite::WorkflowProfile.find(pt.workflow_profile_id).workflow_id
      pt.save
    }
  end
end

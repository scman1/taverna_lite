class AddWorkflowIdToTavernaLiteWorkflowProfiles < ActiveRecord::Migration
  def change
    add_column :taverna_lite_workflow_profiles, :workflow_id, :integer
  end
end

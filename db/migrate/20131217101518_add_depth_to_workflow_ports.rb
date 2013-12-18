class AddDepthToWorkflowPorts < ActiveRecord::Migration
  def change
    add_column :taverna_lite_workflow_ports, :depth, :integer, :default => 0
    add_column :taverna_lite_workflow_ports, :granular_depth, :integer, :default => 0
  end
end

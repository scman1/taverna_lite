class CreateTavernaLiteWorkflowComponents < ActiveRecord::Migration
  def change
    create_table :taverna_lite_workflow_components do |t|
      t.integer :workflow_id
      t.integer :license_id
      t.integer :version
      t.string :family

      t.timestamps
    end
  end
end

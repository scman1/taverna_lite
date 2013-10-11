class ChangePortColumns < ActiveRecord::Migration
  def up
    change_table :taverna_lite_workflow_ports do |t|
      t.rename :display_name, :old_name
      t.rename :display_description, :old_description
      t.rename :sample_value, :example
      t.text :old_example
      t.integer :example_type
    end
  end

  def down
    change_table :taverna_lite_workflow_ports do |t|
      t.rename :old_name, :display_name
      t.rename :old_description, :display_description
      t.rename :example, :sample_value
      t.remove :old_example
      t.remove :example_type
    end
  end
end

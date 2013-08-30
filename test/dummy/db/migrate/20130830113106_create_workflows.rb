class CreateWorkflows < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.string :title
      t.string :author
      t.text :description
      t.string :name
      t.string :workflow_file
      t.integer :my_experiment_id
      t.integer :user_id
      t.boolean :is_shared

      t.timestamps
    end
  end
end

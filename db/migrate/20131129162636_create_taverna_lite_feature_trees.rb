class CreateTavernaLiteFeatureTrees < ActiveRecord::Migration
  def change
    create_table :taverna_lite_feature_trees do |t|
      t.integer :feature_model_id
      t.integer :parent_node_id
      t.string :name
      t.integer :feature_type_id
      t.integer :cardinality_lower_bound
      t.integer :cardinality_upper_bound

      t.timestamps
    end
  end
end

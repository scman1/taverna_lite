class CreateTavernaLiteFeatures < ActiveRecord::Migration
  def change
    create_table :taverna_lite_features do |t|
      t.integer :feature_model_id
      t.integer :parent_node_id
      t.string :name
      t.integer :feature_type_id
      t.integer :cardinality_lower_bound
      t.integer :cardinality_upper_bound
      t.integer :component_id

      t.timestamps
    end
  end
end

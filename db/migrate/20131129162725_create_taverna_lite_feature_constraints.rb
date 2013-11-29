class CreateTavernaLiteFeatureConstraints < ActiveRecord::Migration
  def change
    create_table :taverna_lite_feature_constraints do |t|
      t.string :cnf_clause

      t.timestamps
    end
  end
end

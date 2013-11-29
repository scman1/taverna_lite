class CreateTavernaLiteFeatureModelMetadata < ActiveRecord::Migration
  def change
    create_table :taverna_lite_feature_model_metadata do |t|
      t.integer :feature_model_id
      t.string :description
      t.string :creator
      t.string :email
      t.string :date
      t.string :department
      t.string :organisation
      t.string :address
      t.string :phone
      t.string :website
      t.string :reference

      t.timestamps
    end
  end
end

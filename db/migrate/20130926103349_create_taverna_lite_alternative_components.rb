class CreateTavernaLiteAlternativeComponents < ActiveRecord::Migration
  def change
    create_table :taverna_lite_alternative_components do |t|
      t.integer :component_id
      t.integer :alternative_id
      t.string :note

      t.timestamps
    end
  end
end

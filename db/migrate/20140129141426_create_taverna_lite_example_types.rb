class CreateTavernaLiteExampleTypes < ActiveRecord::Migration
  def change
    create_table :taverna_lite_example_types do |t|
      t.string :name

      t.timestamps
    end
  end
end

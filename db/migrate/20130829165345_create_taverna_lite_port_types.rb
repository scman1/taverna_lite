class CreateTavernaLitePortTypes < ActiveRecord::Migration
  def change
    create_table :taverna_lite_port_types do |t|
      t.string :name

      t.timestamps
    end
  end
end

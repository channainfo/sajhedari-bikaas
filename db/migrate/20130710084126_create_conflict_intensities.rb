class CreateConflictIntensities < ActiveRecord::Migration
  def change
    create_table :conflict_intensities do |t|
      t.string :name

      t.timestamps
    end
  end
end

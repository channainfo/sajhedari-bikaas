class RemoveStateIntensityTypeFromConflictCaseRelation < ActiveRecord::Migration
  def up
  	remove_column :conflict_cases, :conflict_type_id
  	remove_column :conflict_cases, :conflict_state_id
  	remove_column :conflict_cases, :conflict_intensity_id
  	drop_table :conflict_intensities
  	drop_table :conflict_states
  	drop_table :conflict_types
  	add_column :conflict_cases, :conflict_type, :integer
    add_column :conflict_cases, :conflict_state, :integer
    add_column :conflict_cases, :conflict_intensity, :integer
  end

  def down
  	create_table :conflict_intensities do |t|
      t.string :name
      t.timestamps
    end

    create_table :conflict_states do |t|
      t.string :name
      t.timestamps
    end

    create_table :conflict_types do |t|
      t.string :name
      t.timestamps
    end
    remove_column :conflict_cases, :conflict_type
  	remove_column :conflict_cases, :conflict_state
  	remove_column :conflict_cases, :conflict_intensity
    add_column :conflict_cases, :conflict_type_id, :integer, references: :conflict_types
    add_column :conflict_cases, :conflict_state_id, :integer, references: :conflict_states
    add_column :conflict_cases, :conflict_intensity_id, :integer, references: :conflict_intensities
  end
end

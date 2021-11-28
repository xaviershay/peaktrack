class AddSyncCompletedAtToAthlete < ActiveRecord::Migration[6.1]
  def change
    add_column :athletes, :sync_completed_at, :datetime, null: true
  end
end

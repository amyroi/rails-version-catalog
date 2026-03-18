class CreateQueueRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :queue_runs do |t|
      t.string :input, null: false
      t.string :status, null: false, default: "queued"
      t.text :output
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end
  end
end

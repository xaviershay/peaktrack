class InitialModels < ActiveRecord::Migration[6.1]
  def change
    create_table :athletes, id: false do |t|
      t.column :id, :bigint, null: false, primary_key: true
      t.string :name, null: false
      t.string :profile_photo_url, null: false
      t.string :oauth_token, null: false
      t.datetime :oldest_activity_at, null: false

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    create_table :activities, id: false do |t|
      t.column :id, :bigint, null: false, primary_key: true
      t.references :athlete, null: false
      t.datetime :started_at, null: false
      t.string :route_summary, null: false
      t.string :route, null: true

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end

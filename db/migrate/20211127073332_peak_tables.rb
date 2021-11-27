class PeakTables < ActiveRecord::Migration[6.1]
  def change
    create_table :peaks, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.string :name, null: false
      t.integer :elevation, null: false

      # Deliberately not depending on PostGIS here (yet)
      # Our needs a pretty simple and easier for me to work in Ruby
      t.decimal :lat, null: false
      t.decimal :lon, null: false

      t.timestamps null: false
    end

    create_table :activity_peaks do |t|
      t.references :activity, null: false
      t.references :peak, null: false
    end

    create_table :regions, id: false do |t|
      t.bigint :id, null: false, primary_key: true
      t.string :name, null: false

      t.timestamps null: false
    end

    create_table :region_peaks do |t|
      t.references :region, null: false
      t.references :peak, null: false
    end
  end
end

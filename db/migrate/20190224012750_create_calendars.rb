class CreateCalendars < ActiveRecord::Migration[5.2]
  def change
    create_table :calendars do |t|
      t.string :name
      t.string :discord_identifier
      t.integer :user_id

      t.timestamps
    end

    create_table :events do |t|
      t.string :name
      t.string :location
      t.integer :recurring_type
      t.datetime :start
      t.datetime :end
      t.integer :user_id
      t.integer :calendar_id

      t.timestamps
    end

    create_table :participants do |t|
      t.integer :user_id
      t.integer :event_id

      t.timestamps
    end

    add_index :participants, [:event_id, :user_id]
  end
end

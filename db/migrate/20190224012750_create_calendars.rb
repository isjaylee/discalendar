class CreateCalendars < ActiveRecord::Migration[5.2]
  def change
    create_table :calendars do |t|
      t.string :name
      t.string :discord_identifier, unqiue: true
      t.integer :user_id

      t.timestamps
    end

    create_table :events do |t|
      t.string :name
      t.string :location
      t.integer :recurring_type
      t.datetime :starting
      t.datetime :ending
      t.string :discord_message_identifier
      t.integer :user_id
      t.integer :calendar_id

      t.timestamps
    end

    create_table :participants do |t|
      t.integer :user_id
      t.integer :event_id

      t.timestamps
    end

    create_table :members do |t|
      t.integer :user_id
      t.integer :calendar_id

      t.timestamps
    end

    add_index :participants, [:event_id, :user_id], unique: true
    add_index :members, [:calendar_id, :user_id], unique: true
  end
end

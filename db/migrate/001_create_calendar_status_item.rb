class CreateCalendarStatusItem < ActiveRecord::Migration

  def self.up
    create_table :calendar_status_items do |t|
      t.references :user, :default => 0
      t.date :date, :null => false
      t.integer :status, :null => false, :default => 0

      t.timestamps
    end

    add_index :calendar_status_items, [:user_id, :date], :unique => true 
  end

  def self.down
    drop_table :calendar_status_items
  end

end
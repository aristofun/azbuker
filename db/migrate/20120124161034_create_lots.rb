class CreateLots < ActiveRecord::Migration
  def change
    create_table :lots do |t|
      t.integer :user_id, :null => false
      t.integer :book_id, :null => false
      t.boolean :is_active, :null => false, :default => true

      t.integer :price
      t.string :comment
      t.boolean :can_deliver, :default => false
      t.boolean :can_postmail, :default => false

      # Book repeated columns  (if null - parent book used)
      t.string :skypename, :limit => 34
      t.string :phone, :limit => 25
      t.integer :cityid, :null => false

      t.attachment :cover
      t.timestamps

    end
    add_index :lots, :user_id
    add_index :lots, :book_id
    add_index :lots, :cityid
    add_index :lots, :id
  end
end

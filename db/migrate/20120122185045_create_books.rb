class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :ozon_coverid
      #t.string :authorstring
      t.string :ozonid
      # best cover available (usually 200x300 px)
      # if ozonid not set - this is uploaded full path from user
      t.string :coverpath_x300
      t.string :coverpath_x200
      t.string :coverpath_x120

      t.integer :genre, :default => 0

      t.integer :lots_count, :default => 0
      t.integer :min_price

      t.timestamps
    end

    add_index :books, :genre
    add_index :books, :id
  end
end

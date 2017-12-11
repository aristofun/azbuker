class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :first
      t.string :middle
      t.string :last, :null => false
      t.string :full, :null => false
      t.string :short, :null => false

      t.timestamps
    end

    add_index :authors, [:last, :first, :middle] #, :unique => true
    add_index :authors, :full #, :unique => true
    add_index :authors, :id #, :unique => true
  end
end

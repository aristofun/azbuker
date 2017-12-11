class CreateOzBooks < ActiveRecord::Migration
  def change
    create_table :oz_books do |t|
      t.string :title
      t.string :ozon_coverid
      t.integer :ozonid
      t.integer :genre
      t.string :auth_last
      t.string :auth_all
    end
  end
end

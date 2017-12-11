class AddSearchIndexToBooksAuthors < ActiveRecord::Migration
  def up
    execute "create index book_title_ts on books using gin(to_tsvector('russian', books.title))"
    execute "create index author_name_ts on authors using gin(to_tsvector('russian', authors.full))"
  end

  def down
    execute "drop index author_name_ts"
    execute "drop index book_title_ts"
  end
end

class AddIndexesToBooks < ActiveRecord::Migration
  def up
    execute 'create index book_title on books (lower(books.title) varchar_pattern_ops)'
    execute 'create index authors_last_lower on authors (lower(authors.last) varchar_pattern_ops)'
    execute 'create index authors_full_lower on authors (lower(authors.full) varchar_pattern_ops)'
    execute 'create index ozbook_title on oz_books (lower(oz_books.title) varchar_pattern_ops)'
    execute 'create index ozbook_auth_last on oz_books (lower(oz_books.auth_last) varchar_pattern_ops)'
    execute 'create index ozbook_auth_all on oz_books (lower(oz_books.auth_all) varchar_pattern_ops)'
  end

  def down
    execute 'drop index book_title'
    execute 'drop index authors_last_lower'
    execute 'drop index authors_full_lower'
    execute 'drop index ozbook_title'
    execute 'drop index ozbook_auth_last'
    execute 'drop index ozbook_auth_all'
  end

end

#require File.expand_path("../../../spec/factories/users.rb", __FILE__)

namespace :db do
  desc "Fill database with sample data <db:populate[users, authors, books/author, lots/book]> "
  task :populate, [:num_users, :num_authors, :books_per_author, :lots_per_book] => [:environment] do |t, args|

    num_users = args[:num_users].to_i
    num_authors = args[:num_authors].to_i
    books_per_author = args[:books_per_author].to_i
    lots_per_book = args[:lots_per_book].to_i

    #Rake::Task["db:reset"].invoke
    Lot.delete_all
    User.delete_all
    Book.delete_all
    Author.delete_all

    puts args

    puts "Creating #{num_users} users..."
    all_users = []
    num_users.times do
      usr = FactoryBot.create(:user, :confirmed_at => 1.second.ago)
      all_users << usr
      print " usr:#{usr.id},"
    end

    puts "\nCreating #{num_authors} authors w. #{books_per_author} b/author..."
    num_authors.times do
      author = FactoryBot.create(:author)
      print "#{author.id},"
      books_per_author.times do
        FactoryBot.create(:book, :authors => [author])
      end
    end


    puts "Generating Lots..."
    Book.all.each do |book|
      print " [book:#{book.id}, author:#{book.authors[0].id}], "
      lots_per_book.times do
        FactoryBot.create(:lot, :user => all_users[rand(num_users)], :book => book)
      end
    end

    system("rake db:test:prepare")
  end
end




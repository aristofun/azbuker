# coding: utf-8
require 'faker'

FactoryBot.define do
  factory :lot do
    user_id 1
    book_id 1

    sequence(:price) { |n| n%571 }
    sequence(:comment) { |n| "Эй ты номер #{(n%200)}+ #{Faker::Lorem.sentence(3)}" }
    sequence(:can_deliver) { |n| (n%3 == 0) }
    sequence(:can_postmail) { |n| (n%5 == 0) }
    sequence(:cityid) { |n| (n % 15) - 1 }
  end

  #factory :lot_w_user, :parent => :book do |book|
  #    book.after(:create) { |b|
  #      FactoryBot.create(:author, :books => [b])
  #    }
  #  end
end

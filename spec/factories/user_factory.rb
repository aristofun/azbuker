# coding: utf-8
# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :user do
    #name { |n| "Ivan #{n}-й" }
    sequence(:email) { |n| "test#{n}@azbooker.ru" }
    sequence(:password) { |n| "foobar#{n}" }
    sequence(:skypename) { |n| "imskype_#{n}" }
    sequence(:cityid) { |n| (n % 15) - 1 }
    sequence(:phone) { |n| "578 998-35-5#{n}" }
    agreement "1"
    
    after(:create) do |user|
      user.confirm!
    end

    trait :admin do
      admin true
    end
  end
end

puts ENV["RAILS_ENV"]

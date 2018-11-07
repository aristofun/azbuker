# coding: utf-8

FactoryBot.define do
  factory :oz_book do
    sequence(:title) { |n| n % 3 == 0 ? "Roman indle-#{n%31}"
    : "#{%w(А Б И К В Г О Е).sample}оман в чашу-#{n%31}" }
    sequence(:ozon_coverid) { |n| 1004460093 + 3*n }
    sequence(:ozonid) { |n| n*2 + 7 }

    sequence(:genre) { |n| n%8 - 1 }
    sequence(:auth_last) { |n| "пушкен-#{n}" }
    sequence(:auth_all) { |n| "Ива#{n}n Пушкен-#{n}, Карабейкин" }
  end
end

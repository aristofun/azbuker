# coding: utf-8

FactoryBot.define do
  factory :book do
    sequence(:title) { |n| n % 3 == 0 ? "Roman indle-#{n%31}"
        : "#{%w(А Б И К В Г О Е).sample}оман в чашу-#{n%31}" }
    sequence(:ozon_coverid) { |n| 1004460093 + 3*n }
    sequence(:ozonid) { |n| n*2 + 7 }
    sequence(:coverpath_x300) { |n| "/assets/#{n*7}/#{n*n%1214}/234_200big.jpg" }
    sequence(:coverpath_x120) { |n| "/assets/#{n%9*5}/#{n}/234_120x120.jpg" }
    sequence(:coverpath_x200) { |n| "/assets/#{n*3}/#{n%131}/234_200x200.jpg" }

    sequence(:genre) { |n| n%8 - 1 }
    sequence(:min_price) { nil }
  end

  factory :book_w_author, :parent => :book do |book|
    book.after(:create) { |b|
      FactoryBot.create(:author, :books => [b])
    }
  end
end


FactoryBot.define do
  factory :author do
    sequence(:first) { |n| "Александр#{n}й" }
    sequence(:middle) { |n| "Сэрг#{"е"*n}вич" }
    sequence(:last) { |n| n % 3 == 0 ? "Pushkin#{n}" : "Пушкен#{n}" }
  end
end

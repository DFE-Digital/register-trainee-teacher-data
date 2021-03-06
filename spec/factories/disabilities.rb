# frozen_string_literal: true

FactoryBot.define do
  factory :disability do
    sequence(:name) { |n| "disability #{n}" }
    description { "some disability text" }
  end
end

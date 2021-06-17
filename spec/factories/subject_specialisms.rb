# frozen_string_literal: true

FactoryBot.define do
  factory :subject_specialism do
    allocation_subject

    sequence(:name) { |s| "subject #{s}" }
  end
end

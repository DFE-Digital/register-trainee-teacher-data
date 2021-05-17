# frozen_string_literal: true

FactoryBot.define do
  factory :abstract_trainee, class: Trainee do
    sequence :trainee_id do |n|
      year = (course_start_date || Faker::Date.between(from: 10.years.ago, to: Time.zone.today)).strftime("%y").to_i

      "#{year}/#{year + 1}-#{n}"
    end

    provider

    training_route { TRAINING_ROUTE_ENUMS[:assessment_only] }

    first_names { Faker::Name.first_name }
    middle_names { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    gender { Trainee.genders.keys.sample }
    slug { SecureRandom.base58(Sluggable::SLUG_LENGTH) }

    diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS.values.sample }
    ethnic_group { Diversities::ETHNIC_GROUP_ENUMS.values.sample }
    ethnic_background { nil }
    additional_ethnic_background { nil }
    disability_disclosure { (Diversities::DISABILITY_DISCLOSURE_ENUMS.values - %w[disabled]).sample }

    address_line_one { Faker::Address.street_address }
    address_line_two { Faker::Address.street_name }
    town_city { Faker::Address.city }
    postcode { Faker::Address.postcode }
    international_address { nil }
    locale_code { :uk }
    email { "#{first_names}.#{last_name}@example.com" }

    factory :trainee do
      date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    end

    factory :trainee_for_form do
      transient do
        form_dob { Faker::Date.birthday(min_age: 18, max_age: 65) }
      end
      add_attribute("date_of_birth(3i)") { form_dob.day.to_s }
      add_attribute("date_of_birth(2i)") { form_dob.month.to_s }
      add_attribute("date_of_birth(1i)") { form_dob.year.to_s }
    end

    trait :not_started do
      trainee_id { nil }
      first_names { nil }
      middle_names { nil }
      last_name { nil }
      gender { nil }
      date_of_birth { nil }

      diversity_disclosure { nil }
      ethnic_group { nil }
      ethnic_background { nil }
      additional_ethnic_background { nil }
      disability_disclosure { nil }

      address_line_one { nil }
      address_line_two { nil }
      town_city { nil }
      postcode { nil }
      international_address { nil }
      locale_code { nil }
      email { nil }
      commencement_date { nil }
    end

    trait :in_progress do
      with_course_details
      with_start_date
      degrees { [build(:degree, :uk_degree_with_details)] }
    end

    trait :completed do
      in_progress
      nationalities { [build(:nationality)] }
      progress do
        Progress.new(
          personal_details: true,
          contact_details: true,
          diversity: true,
          degrees: true,
          course_details: true,
          training_details: true,
          placement_details: true,
          schools: true,
        )
      end
    end

    trait :with_course_details do
      subject { Dttp::CodeSets::CourseSubjects::MAPPING.keys.sample }
      course_code { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
      course_age_range { Dttp::CodeSets::AgeRanges::MAPPING.keys.sample }
      course_start_date { Faker::Date.between(from: 10.years.ago, to: 2.days.ago) }
      course_end_date { Faker::Date.between(from: course_start_date + 1.day, to: Time.zone.today) }
    end

    trait :with_start_date do
      commencement_date { Faker::Date.between(from: 6.months.from_now, to: Time.zone.today) }
    end

    trait :diversity_disclosed do
      diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] }
    end

    trait :diversity_not_disclosed do
      diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] }
    end

    trait :with_ethnic_background do
      ethnic_background { Dttp::CodeSets::Ethnicities::MAPPING.keys.sample }
    end

    trait :disabled do
      disability_disclosure { Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] }
    end

    trait :with_placement_assignment do
      placement_assignment_dttp_id { SecureRandom.uuid }
    end

    trait :with_outcome_date do
      outcome_date { Faker::Date.in_date_period }
    end

    trait :provider_led_postgrad do
      training_route { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
    end

    trait :early_years_undergrad do
      training_route { TRAINING_ROUTE_ENUMS[:early_years_undergrad] }
    end

    trait :school_direct_tuition_fee do
      training_route { TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] }
    end

    trait :school_direct_salaried do
      training_route { TRAINING_ROUTE_ENUMS[:school_direct_salaried] }
    end

    trait :draft do
      state { TRAINEE_STATE_ENUMS[:draft] }
    end

    trait :submitted_for_trn do
      state { TRAINEE_STATE_ENUMS[:submitted_for_trn] }
      submitted_for_trn_at { Time.zone.now }
      dttp_id { SecureRandom.uuid }
    end

    trait :trn_received do
      submitted_for_trn
      state { TRAINEE_STATE_ENUMS[:trn_received] }
      dttp_id { SecureRandom.uuid }
    end

    trait :recommended_for_award do
      state { TRAINEE_STATE_ENUMS[:recommended_for_award] }
      recommended_for_award_at { Time.zone.now }
    end

    trait :withdrawn do
      state { TRAINEE_STATE_ENUMS[:withdrawn] }
      withdraw_date { Faker::Date.in_date_period }
    end

    trait :deferred do
      submitted_for_trn
      state { TRAINEE_STATE_ENUMS[:deferred] }
      defer_date { Faker::Date.in_date_period }
    end

    trait :reinstated do
      state { TRAINEE_STATE_ENUMS[:trn_received] }
      defer_date { Faker::Date.in_date_period }
      reinstate_date { Faker::Date.in_date_period }
    end

    trait :awarded do
      state { TRAINEE_STATE_ENUMS[:awarded] }
    end

    trait :with_dttp_dormancy do
      deferred
      dormancy_dttp_id { SecureRandom.uuid }
    end

    trait :withdrawn_on_another_day do
      withdraw_date { Faker::Date.in_date_period }
    end

    trait :withdrawn_for_specific_reason do
      withdraw_date { Time.zone.today }
      withdraw_reason { WithdrawalReasons::SPECIFIC.sample }
    end

    trait :withdrawn_for_another_reason do
      withdraw_date { Faker::Date.in_date_period }
      withdraw_reason { WithdrawalReasons::FOR_ANOTHER_REASON }
      additional_withdraw_reason { Faker::Lorem.paragraph }
    end

    trait :with_related_courses do
      training_route { (TRAINING_ROUTES_FOR_TRAINEE.keys & TRAINING_ROUTES_FOR_COURSE.keys).sample }

      transient do
        courses_count { 5 }
      end

      after(:create) do |trainee, evaluator|
        create_list(:course, evaluator.courses_count,
                    accredited_body_code: trainee.provider.code,
                    route: trainee.training_route)

        trainee.reload
      end
    end

    trait :with_lead_school do
      association :lead_school, factory: %i[school lead]
    end

    trait :with_employing_school do
      association :employing_school, factory: :school
    end

    trait :with_apply_application do
      apply_application
    end
  end
end

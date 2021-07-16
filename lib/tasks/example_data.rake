# frozen_string_literal: true

require "faker"
require "factory_bot"
require Rails.root.join("spec/support/api_stubs/apply_api")
require Rails.root.join("spec/support/publish_courses_with_subjects")

REAL_PUBLISH_COURSES_WITH_SUBJECTS = {
  "Primary" => ["Primary"],
  "Art and design" => ["Art and design"],
  "Biology" => ["Biology"],
  "Chemistry" => ["Chemistry"],
  "Computing" => ["Computing"],
  "Design and Technology" => ["Design and technology"],
  "English" => ["English"],
  "Geography" => ["Geography"],
  "History" => ["History"],
  "Mathematics" => ["Mathematics"],
  "Modern Languages" => ["Modern languages (other)"],
  "Music" => ["Music"],
  "Physical Education" => ["Physical education"],
  "Physics" => ["Physics"],
  "Primary with Mathematics" => ["Primary with mathematics"],
  "Religious Education" => ["Religious education"],
  "Art and Design" => ["Art and design"],
  "Business Studies" => ["Business studies"],
  "Drama" => ["Drama"],
  "Health and Social Care" => ["Health and social care"],
  "Modern languages" => ["Modern languages (other)"],
  "PE with EBacc" => ["Physical education"],
  "Primary (SEND)" => ["Primary"],
  "Psychology" => ["Psychology"],
  "Religious education" => ["Religious education"],
  "Social Sciences" => ["Social sciences"],
  "Modern Languages (French and Spanish)" => %w[French Spanish],
  "Computer Science" => ["Computing"],
  "Design and technology" => ["Design and technology"],
  "Modern Languages (Spanish)" => ["Spanish"],
}.freeze

namespace :example_data do
  desc "Create personas, their providers and a selection of trainees"
  task generate: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    Faker::Config.locale = "en-GB"

    # Base our example data on the currently switched-on feature flags
    enabled_routes = TRAINING_ROUTE_FEATURE_FLAGS.select { |flag| FeatureService.enabled?("routes.#{flag}") }
                                                 .compact
                                                 .push(:assessment_only)
    enabled_course_routes = enabled_routes & TRAINING_ROUTES_FOR_COURSE.keys.map(&:to_sym)

    # Create some schools
    employing_schools = FactoryBot.create_list(:school, 50)
    lead_schools = FactoryBot.create_list(:school, 50, lead_school: true)

    # Create some subjects
    REAL_PUBLISH_COURSES_WITH_SUBJECTS.values.flatten.uniq.map { |name| FactoryBot.create(:subject, name: name) }

    # For each persona...
    PERSONAS.each do |persona_attributes|
      # Create the persona
      persona = Persona.find_or_create_by!(first_name: persona_attributes[:first_name],
                                           last_name: persona_attributes[:last_name],
                                           email: persona_attributes[:email],
                                           dttp_id: SecureRandom.uuid,
                                           system_admin: persona_attributes[:system_admin])

      next unless persona_attributes[:provider]

      # Create the provider for that persona
      provider = Provider.find_or_create_by!(
        name: persona_attributes[:provider],
        dttp_id: SecureRandom.uuid,
        code: Faker::Alphanumeric.alphanumeric(number: 3).upcase,
      )

      persona.update!(provider: provider)

      # For each of the course routes enabled...
      enabled_course_routes.each do |route|
        REAL_PUBLISH_COURSES_WITH_SUBJECTS.each do |course_name, subject_names|
          FactoryBot.build(:course, accredited_body_code: provider.code, route: route, name: course_name) { |course|
            course.subjects = Subject.where(name: subject_names)
          }.save!
        end
      end

      provider_course_codes = provider.courses.pluck(:code)

      # For each route that's enabled...
      enabled_routes.each do |route|
        # And for all possible trainee states...
        Trainee.states.keys.map(&:to_sym).each do |state|
          # Create small number of trainees
          sample_size = rand(1...4)

          sample_size.times do |sample_index|
            attrs = { created_at: Faker::Date.between(from: 100.days.ago, to: 50.days.ago) }
            attrs.merge!(provider: provider) if provider

            # Some route-specific logic, but could move into factories too
            attrs.merge!(lead_school: lead_schools.sample) if %i[school_direct_salaried school_direct_tuition_fee].include?(route)
            attrs.merge!(employing_school: employing_schools.sample) if route == :school_direct_salaried
            attrs.merge!(course_code: provider_course_codes.sample) unless state == :draft

            # Make *roughly* half of draft trainees apply drafts
            if state == :draft && sample_index < sample_size / 2
              attrs.merge!(course_code: provider_course_codes.sample,
                           apply_application: FactoryBot.create(:apply_application, provider: provider))
            end

            trainee = FactoryBot.create(:trainee, route, state, attrs)

            # Add an extra nationality 20% of the time
            trainee.nationalities << Nationality.all.sample if rand(10) < 2
          end
        end
      end
    end
  end
end

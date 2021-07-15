# frozen_string_literal: true

module Trainees
  class CreateFromApply
    include ServicePattern

    def initialize(application:)
      @application = application
    end

    def call
      validate_and_sanitise_trainee
      trainee.save!
      trainee
    end

  private

    attr_reader :application

    def trainee
      @trainee ||= Trainee.new(mapped_attributes)
    end

    def mapped_attributes
      {
        apply_application: application,
        provider: provider,
        first_names: raw_trainee["first_name"],
        last_name: raw_trainee["last_name"],
        date_of_birth: raw_trainee["date_of_birth"],
        gender: gender,
        ethnic_group: ethnic_group,
        ethnic_background: raw_trainee["ethnic_background"],
        diversity_disclosure: diversity_disclosure,
        email: raw_contact_details["email"],
        training_route: course&.route,
        course_subject_one: course&.name,
        course_code: course&.code,
        course_age_range: course&.age_range,
        course_start_date: course&.start_date,
        course_end_date: course&.end_date,
        degrees: degrees,
        disabilities: disabilities,
        nationalities: nationalities,
      }.merge(address)
    end

    def degrees
      application.degrees.map { |degree| Degree.new(degree) }
    end

    def address
      raw_contact_details["country"] == "GB" ? uk_address : international_address
    end

    def international_address
      {
        international_address: raw_contact_details["address_line1"],
        locale_code: Trainee.locale_codes[:non_uk],
      }
    end

    def uk_address
      {
        address_line_one: raw_contact_details["address_line1"],
        address_line_two: raw_contact_details["address_line2"],
        town_city: raw_contact_details["address_line3"],
        postcode: raw_contact_details["postcode"],
        locale_code: Trainee.locale_codes[:uk],
      }
    end

    def gender
      ApplyApi::CodeSets::Genders::MAPPING[raw_trainee["gender"]]
    end

    def ethnic_group
      ApplyApi::CodeSets::Ethnicities::MAPPING[raw_trainee["ethnic_group"]]
    end

    def diversity_disclosure
      return Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] if diversity_disclosed?

      Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
    end

    def diversity_disclosed?
      raw_trainee.slice("disabilities", "ethnic_group", "ethnic_background").values.any?(&:present?)
    end

    def disabilities
      @disabilities ||= Disability.where(name: disability_names)
    end

    def disability_names
      raw_trainee["disabilities"].map { |disability| ApplyApi::CodeSets::Disabilities::MAPPING[disability] }
    end

    def nationalities
      @nationalities ||= Nationality.where(name: nationality_names)
    end

    def nationality_names
      raw_trainee["nationality"].map { |nationality| ApplyApi::CodeSets::Nationalities::MAPPING[nationality] }
    end

    def course
      @course ||= provider.courses.find_by(code: raw_course["course_code"])
    end

    def provider
      @provider ||= application.provider
    end

    def raw_trainee
      @raw_trainee ||= application.application_attributes["candidate"]
    end

    def raw_contact_details
      @raw_contact_details ||= application.application_attributes["contact_details"]
    end

    def raw_course
      @raw_course ||= application.application_attributes["course"]
    end

    def validate_and_sanitise_trainee
      trainee.valid?
      trainee.degrees.each do |degree|
        degree.errors.each do |error|
          degree.send("#{error.attribute}=", nil)
        end
      end
    end
  end
end

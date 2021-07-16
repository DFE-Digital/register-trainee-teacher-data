# frozen_string_literal: true

module Degrees
  class MapFromApply
    include ServicePattern

    def initialize(attributes:)
      @attributes = attributes
    end

    def call
      common_params.merge(degree_params)
    end

  private

    attr_reader :attributes

    def degree_params
      uk_degree? ? uk_degree_params : non_uk_degree_params
    end

    def common_params
      {
        subject: attributes["subject"],
        graduation_year: attributes["award_year"],
      }
    end

    def uk_degree_params
      {
        locale_code: Trainee.locale_codes[:uk],
        uk_degree: attributes["qualification_type"],
        institution: institution,
        grade: attributes["grade"],
      }
    end

    def non_uk_degree_params
      {
        locale_code: Trainee.locale_codes[:non_uk],
        non_uk_degree: attributes["comparable_uk_degree"],
        country: country,
      }
    end

    def uk_degree?
      attributes["non_uk_qualification_type"].nil?
    end

    def institution
      attributes["institution_details"].split(",").first
    end

    def country
      Dttp::CodeSets::Countries::MAPPING.find { |_, v| v[:country_code] == attributes["hesa_degctry"] }.first
    end
  end
end

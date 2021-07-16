# frozen_string_literal: true

module DegreesHelper
  include ApplicationHelper

  def degree_options
    options = Dttp::CodeSets::DegreeTypes::MAPPING.map do |name, attributes|
      next if Dttp::CodeSets::DegreeTypes::NON_UK.include?(name)

      data = {
        "data-synonyms" => attributes[:abbreviation],
        "data-append" => attributes[:abbreviation] && tag.strong("(#{attributes[:abbreviation]})"),
        "data-boost" => (Dttp::CodeSets::DegreeTypes::COMMON.include?(name) ? 1.5 : 1),
      }
      [name, name, data]
    end
    empty_result = [nil, nil, nil]
    options.unshift(empty_result).compact
  end

  def institutions_options
    to_options(Degree::INSTITUTIONS)
  end

  def subjects_options
    to_options(Degree::SUBJECTS)
  end

  def countries_options
    to_options(countries)
  end

  def grades
    Dttp::CodeSets::Grades::MAPPING.keys
  end

private

  def countries
    Dttp::CodeSets::Countries::MAPPING.keys
  end
end

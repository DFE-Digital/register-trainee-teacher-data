# frozen_string_literal: true

class Degree < ApplicationRecord
  include Sluggable

  INSTITUTIONS = Dttp::CodeSets::Institutions::MAPPING.keys
  SUBJECTS = Dttp::CodeSets::DegreeSubjects::MAPPING.keys

  validates :locale_code, presence: true
  validates :institution, presence: true, on: :uk
  validates :country, presence: true, on: :non_uk
  validates :subject, presence: true, on: %i[uk non_uk]
  validates :uk_degree, presence: true, on: :uk
  validates :non_uk_degree, presence: true, on: :non_uk
  validates :grade, presence: true, on: :uk
  validates :graduation_year, presence: true, on: %i[uk non_uk]
  validate :graduation_year_valid, if: -> { graduation_year.present? }
  validates :institution, inclusion: { in: INSTITUTIONS }, allow_nil: true
  validates :subject, inclusion: { in: SUBJECTS }, allow_nil: true

  belongs_to :trainee

  enum locale_code: { uk: 0, non_uk: 1 }

  audited associated_with: :trainee

  MAX_GRAD_YEARS = 60

  def graduation_year_valid
    errors.add(:graduation_year, :future) if graduation_year > next_year
    errors.add(:graduation_year, :invalid) unless graduation_year.between?(next_year - MAX_GRAD_YEARS, next_year)
  end

  def non_uk_degree_non_enic?
    non_uk_degree == NON_ENIC
  end

  # other_grade should be nil if grade isn't 'Other'
  def other_grade
    if grade == "Other"
      self[:other_grade]
    end
  end

private

  def next_year
    Time.zone.now.year.next
  end
end

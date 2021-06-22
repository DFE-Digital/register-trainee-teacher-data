# frozen_string_literal: true

class SubjectSpecialism < ApplicationRecord
  belongs_to :allocation_subject, inverse_of: :subject_specialisms

  scope :order_by_name, -> { order("LOWER(name)") }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end

# frozen_string_literal: true

class ApplyApplication < ApplicationRecord
  belongs_to :provider
  has_one :trainee

  validates :application, presence: true
end

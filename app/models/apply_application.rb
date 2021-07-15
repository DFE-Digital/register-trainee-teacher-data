# frozen_string_literal: true

class ApplyApplication < ApplicationRecord
  belongs_to :provider
  has_one :trainee

  validates :application, presence: true

  def application_attributes
    parsed_application["attributes"]
  end

  def degrees
    raw_degrees.map { |degree| Degrees::MapFromApply.call(attributes: degree) }
  end

private

  def parsed_application
    @parsed_application ||= JSON.parse(application)
  end

  def raw_degrees
    application_attributes["qualifications"]["degrees"]
  end
end

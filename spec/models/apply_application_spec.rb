# frozen_string_literal: true

require "rails_helper"

describe ApplyApplication do
  describe "associations" do
    it { is_expected.to belong_to(:provider) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:application) }
  end
end

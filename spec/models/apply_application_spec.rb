# frozen_string_literal: true

require "rails_helper"

describe ApplyApplication do
  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to have_one(:trainee) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:application) }
  end
end

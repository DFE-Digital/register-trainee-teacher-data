# frozen_string_literal: true

require "rails_helper"

describe DegreesHelper do
  include DegreesHelper

  describe "#degree_options" do
    let(:degree_type) { "Bachelor of Arts" }
    let(:degree_abbreviation) { "BA" }
    let(:non_uk_degree_type) { "Unknown" }
    let(:non_uk_degree_types) { %w[Unknown] }

    before do
      stub_const("Dttp::CodeSets::DegreeTypes::NON_UK", [non_uk_degree_type])
      stub_const("Dttp::CodeSets::DegreeTypes::MAPPING", {
        degree_type => { abbreviation: degree_abbreviation },
        non_uk_degree_type => { abbreviation: nil },
      })
      stub_const("Dttp::CodeSets::DegreeTypes::COMMON", [degree_type])
    end

    it "iterates over array and prints out correct degree options" do
      expect(degree_options).to match([
        [nil, nil, nil],
        [
          degree_type,
          degree_type,
          { "data-append" => "<strong>(#{degree_abbreviation})</strong>", "data-boost" => 1.5, "data-synonyms" => degree_abbreviation },
        ],
      ])
    end
  end

  describe "#institutions_options" do
    before do
      stub_const("Degree::INSTITUTIONS", %w[institution])
    end

    it "iterates over array and prints out correct institutions values" do
      expect(institutions_options.size).to be 2
      expect(institutions_options.first.value).to be_nil
      expect(institutions_options.second.value).to eq "institution"
      expect(institutions_options.second.text).to eq "Institution"
    end
  end

  describe "#subjects_options" do
    before do
      stub_const("Degree::SUBJECTS", %w[subject])
    end

    it "iterates over array and prints out correct subjects values" do
      expect(subjects_options.size).to be 2
      expect(subjects_options.first.value).to be_nil
      expect(subjects_options.second.value).to eq "subject"
      expect(subjects_options.second.text).to eq "Subject"
    end
  end

  describe "#countries_options" do
    before do
      allow(self).to receive(:countries).and_return(%w[country])
    end

    it "iterates over array and prints out correct countries values" do
      expect(countries_options.size).to be 2
      expect(countries_options.first.value).to be_nil
      expect(countries_options.second.value).to eq "country"
      expect(countries_options.second.text).to eq "Country"
    end
  end
end

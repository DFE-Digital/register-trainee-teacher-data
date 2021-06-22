# frozen_string_literal: true

require "rails_helper"

describe CourseDetailsHelper do
  include CourseDetailsHelper

  describe "#course_subjects_options" do
    before do
      create(:subject_specialism, name: Dttp::CodeSets::CourseSubjects::TRAVEL_AND_TOURISM)
    end

    it "iterates over Dttp::CodeSets::CourseSubjects and prints out correct course_subjects values" do
      expect(course_subjects_options.size).to be 71
      expect(course_subjects_options.first.value).to be_nil
      expect(course_subjects_options.second.value).to eq Dttp::CodeSets::CourseSubjects::ANCIENT_HEBREW
    end

    context "when the feature flag is turned on", feature_use_subject_specialisms: true do
      before do
        create(:subject_specialism, name: Dttp::CodeSets::CourseSubjects::BUSINESS_MANAGEMENT)
      end

      it "iterates over subject specialisms and prints out ordered course_subjects" do
        expect(course_subjects_options.size).to be 3
        expect(course_subjects_options.first.value).to be_nil
        expect(course_subjects_options.second.text).to eq "Business and management"
        expect(course_subjects_options.third.value).to eq Dttp::CodeSets::CourseSubjects::TRAVEL_AND_TOURISM
        expect(course_subjects_options.third.text).to eq "Travel and tourism"
      end
    end
  end

  describe "#main_age_ranges_options" do
    before do
      allow(self).to receive(:age_ranges).with(option: :main).and_return(%w[main_age_range])
    end

    it "iterates over array and prints out correct main_age_ranges values" do
      expect(main_age_ranges_options).to contain_exactly "main_age_range"
    end
  end

  describe "#additional_age_ranges_options" do
    before do
      allow(self).to receive(:age_ranges).with(option: :additional).and_return(%w[additional_age_range])
    end

    it "iterates over array and prints out correct additional_age_ranges values" do
      expect(additional_age_ranges_options.size).to be 2
      expect(additional_age_ranges_options.first.value).to be_nil
      expect(additional_age_ranges_options.second.value).to eq "additional_age_range"
    end
  end

  describe "#subjects_for_summary_view" do
    let(:subject_one) { "Biology" }
    let(:subject_two) { "" }
    let(:subject_three) { "" }

    subject { subjects_for_summary_view(subject_one, subject_two, subject_three) }

    it { is_expected.to eq("Biology") }

    context "with lowercased first subject" do
      let(:subject_one) { "applied biology" }

      it { is_expected.to eq("Applied biology") }
    end

    context "with two subjects" do
      let(:subject_two) { "Art and design" }

      it { is_expected.to eq("Biology with Art and design") }
    end

    context "without a second subject" do
      let(:subject_three) { "Mathematics" }

      it { is_expected.to eq("Biology with Mathematics") }
    end

    context "with three subjects" do
      let(:subject_two) { "Art and design" }
      let(:subject_three) { "Mathematics" }

      it { is_expected.to eq("Biology with Art and design and Mathematics") }
    end
  end
end

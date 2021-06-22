# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe Filter do
    subject { described_class.call(trainees: trainees, filters: filters) }

    let!(:generic_trainee) { create(:trainee) }
    let(:filters) { nil }
    let(:trainees) { Trainee.all }

    it { is_expected.to eq(trainees) }

    context "with training_route filter" do
      let!(:provider_led_postgrad_trainee) { create(:trainee, :provider_led_postgrad) }
      let(:filters) { { training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad] } }

      it { is_expected.to eq([provider_led_postgrad_trainee]) }
    end

    context "with state filter" do
      let!(:submitted_for_trn_trainee) { create(:trainee, :submitted_for_trn) }
      let!(:qts_awarded_trainee) { create(:trainee, :qts_awarded) }
      let!(:eyts_awarded_trainee) { create(:trainee, :eyts_awarded) }
      let(:filters) { { state: %w[submitted_for_trn qts_awarded] } }

      it { is_expected.to contain_exactly(submitted_for_trn_trainee, qts_awarded_trainee) }
    end

    context "with subject filter" do
      let(:subject_name) { Dttp::CodeSets::CourseSubjects::BIOLOGY }
      let!(:trainee_with_subject) { create(:trainee, course_subject_one: subject_name) }
      let(:filters) { { subject: subject_name } }

      it { is_expected.to eq([trainee_with_subject]) }

      context "when the feature flag is turned on", feature_use_subject_specialisms: true do
        let!(:trainee_with_subject) { create(:trainee, :with_subject_specialism, subject_name: subject_name) }

        it { is_expected.to eq([trainee_with_subject]) }
      end
    end

    context "with text_search filter" do
      let!(:named_trainee) { create(:trainee, first_names: "Boaty McBoatface") }
      let(:filters) { { text_search: "Boaty" } }

      it { is_expected.to eq([named_trainee]) }
    end
  end
end

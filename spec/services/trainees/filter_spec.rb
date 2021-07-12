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
      let!(:draft_trainee) { create(:trainee, :draft) }
      let!(:submitted_for_trn_trainee) { create(:trainee, :submitted_for_trn) }
      let!(:apply_draft_trainee) { create(:trainee, :with_apply_application) }
      let!(:qts_awarded_trainee) { create(:trainee, :qts_awarded) }
      let!(:eyts_awarded_trainee) { create(:trainee, :eyts_awarded) }

      context "with trn_submitted, qts_awarded and apply_draft trainees" do
        let(:filters) { { state: %w[submitted_for_trn qts_awarded apply_draft] } }

        it { is_expected.to contain_exactly(submitted_for_trn_trainee, qts_awarded_trainee, apply_draft_trainee) }
      end

      context "with only draft trainees" do
        let(:filters) { { state: %w[draft] } }

        it { is_expected.to contain_exactly(draft_trainee, apply_draft_trainee, generic_trainee) }
      end
    end

    context "with subject filter" do
      let(:subject_name) { Dttp::CodeSets::CourseSubjects::BIOLOGY }
      let!(:trainee_with_subject) { create(:trainee, course_subject_one: subject_name) }
      let(:filters) { { subject: subject_name } }

      it { is_expected.to eq([trainee_with_subject]) }
    end

    context "with text_search filter" do
      let!(:named_trainee) { create(:trainee, first_names: "Boaty McBoatface") }
      let(:filters) { { text_search: "Boaty" } }

      it { is_expected.to eq([named_trainee]) }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Trainee do
  context "fields" do
    subject { build(:trainee) }

    it do
      expect(subject).to define_enum_for(:training_route).with_values(
        TRAINING_ROUTE_ENUMS[:assessment_only] => 0,
        TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => 1,
        TRAINING_ROUTE_ENUMS[:early_years_undergrad] => 2,
        TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => 3,
        TRAINING_ROUTE_ENUMS[:school_direct_salaried] => 4,
        TRAINING_ROUTE_ENUMS[:early_years_assessment_only] => 6,
        TRAINING_ROUTE_ENUMS[:early_years_salaried] => 7,
        TRAINING_ROUTE_ENUMS[:early_years_postgrad] => 8,
        TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => 5,
      )
    end

    it { is_expected.to define_enum_for(:locale_code).with_values(uk: 0, non_uk: 1) }
    it { is_expected.to define_enum_for(:gender).with_values(male: 0, female: 1, other: 2, gender_not_provided: 3) }

    it do
      expect(subject).to define_enum_for(:diversity_disclosure).with_values(
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] => 0,
        Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] => 1,
      )
    end

    it do
      expect(subject).to define_enum_for(:disability_disclosure).with_values(
        Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] => 0,
        Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] => 1,
        Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] => 2,
      )
    end

    it do
      expect(subject).to define_enum_for(:training_initiative).with_values(
        ROUTE_INITIATIVES_ENUMS[:future_teaching_scholars] => 0,
        ROUTE_INITIATIVES_ENUMS[:maths_physics_chairs_programme_researchers_in_schools] => 1,
        ROUTE_INITIATIVES_ENUMS[:now_teach] => 2,
        ROUTE_INITIATIVES_ENUMS[:transition_to_teach] => 3,
        ROUTE_INITIATIVES_ENUMS[:no_initiative] => 4,
      )
    end

    it do
      expect(subject).to define_enum_for(:ethnic_group).with_values(
        Diversities::ETHNIC_GROUP_ENUMS[:asian] => 0,
        Diversities::ETHNIC_GROUP_ENUMS[:black] => 1,
        Diversities::ETHNIC_GROUP_ENUMS[:mixed] => 2,
        Diversities::ETHNIC_GROUP_ENUMS[:white] => 3,
        Diversities::ETHNIC_GROUP_ENUMS[:other] => 4,
        Diversities::ETHNIC_GROUP_ENUMS[:not_provided] => 5,
      )
    end

    it do
      expect(subject).to define_enum_for(:bursary_tier).with_values(
        BURSARY_TIER_ENUMS[:tier_one] => 0,
        BURSARY_TIER_ENUMS[:tier_two] => 1,
        BURSARY_TIER_ENUMS[:tier_three] => 2,
      )
    end
  end

  context "scopes" do
    describe "with_award_states" do
      it "returns tainees with the correct training route and state" do
        create(:trainee, :trn_received)
        qts_awarded = create(:trainee, :qts_awarded)
        eyts_recommended = create(:trainee, :eyts_recommended)
        create(:trainee, :eyts_awarded)

        expect(Trainee.with_award_states(:qts_awarded, :eyts_recommended)).to contain_exactly(qts_awarded, eyts_recommended)
      end
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:apply_application).optional }
    it { is_expected.to have_many(:degrees).dependent(:destroy) }
    it { is_expected.to have_many(:nationalisations).dependent(:destroy).inverse_of(:trainee) }
    it { is_expected.to have_many(:nationalities).through(:nationalisations) }
    it { is_expected.to have_many(:trainee_disabilities).dependent(:destroy).inverse_of(:trainee) }
    it { is_expected.to have_many(:disabilities).through(:trainee_disabilities) }
    it { is_expected.to belong_to(:lead_school).class_name("School").optional }
    it { is_expected.to belong_to(:employing_school).class_name("School").optional }
  end

  context "validations" do
    context "slug" do
      subject { create(:trainee) }

      it { is_expected.to validate_uniqueness_of(:slug).case_insensitive }

      context "immutability" do
        let(:original_slug) { subject.slug.dup }

        before do
          original_slug
          subject.regenerate_slug
          subject.reload
        end

        it "is immutable once created" do
          expect(subject.slug).to eq(original_slug)
        end
      end
    end
  end

  context "class methods" do
    describe ".dttp_id" do
      let(:uuid) { "2795182a-43b2-4543-bf83-ad95fbfce7fd" }

      context "when passed as an attribute" do
        it "uses the attribute" do
          trainee = create(:trainee, dttp_id: uuid)
          expect(trainee.dttp_id).to eq(uuid)
        end
      end

      context "when it has already been set" do
        it "raises an exception" do
          trainee = create(:trainee, dttp_id: uuid)

          expect { trainee.dttp_id = uuid }.to raise_error(LockedAttributeError)
        end
      end

      describe "validation" do
        context "when training route is present" do
          subject { build(:trainee, training_route: TRAINING_ROUTE_ENUMS[:assessment_only]) }

          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context "when training route is not present" do
          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors.attribute_names).to include(:training_route)
          end
        end
      end
    end
  end

  context "instance methods" do
    subject { create(:trainee) }

    describe "#sha" do
      let(:expected_sha) { Digest::SHA1.hexdigest(subject.digest) }

      it "returns a SHA of the trainee's current state" do
        expect(subject.sha).to eq(expected_sha)
      end
    end

    describe "#digest" do
      let(:expected_digest) do
        subject.as_json.except(
          "created_at", "updated_at", "dttp_update_sha"
        ).to_json
      end

      it "returns a string representation of the trainee's current state" do
        expect(subject.digest).to include(expected_digest)
      end
    end

    describe "#training_route_manager" do
      it "returns an instance of TrainingRouteManager" do
        expect(subject.training_route_manager).to be_an_instance_of(TrainingRouteManager)
      end
    end

    describe "#requires_placement_details?" do
      it "is delegated to TrainingRouteManager" do
        expect(subject.training_route_manager).to receive(:requires_placement_details?)
        subject.requires_placement_details?
      end
    end

    describe "#apply_application?" do
      subject { trainee.apply_application? }

      context "the trainee has an associated apply application" do
        let(:trainee) { create(:trainee, :with_apply_application) }

        it { is_expected.to be true }
      end

      context "the trainee does not have an associated apply application" do
        let(:trainee) { create(:trainee) }

        it { is_expected.to be false }
      end
    end

    describe "#timeline" do
      context "with cache" do
        before do
          allow(Rails.cache).to receive(:fetch).and_return(double)
        end

        it "caches the timeline event after the initial request" do
          expect(Trainees::CreateTimeline).not_to receive(:call)

          subject.timeline
        end
      end

      context "without cache" do
        it "calls Trainees::CreateTimeline" do
          expect(Trainees::CreateTimeline).to receive(:call).once

          subject.timeline
        end
      end
    end

    describe "#bursary_amount" do
      it "returns the bursary amount for the trainee's route and subject" do
        expect(CalculateBursary).to receive(:for_route_and_subject).once.with(subject.training_route.to_sym, subject.course_subject_one)

        subject.bursary_amount
      end
    end
  end

  describe "#can_apply_for_bursary?" do
    let(:trainee) { create(:trainee) }

    subject { trainee.can_apply_for_bursary? }

    it { is_expected.to be_falsey }

    context "when the trainee is on the early_years_postgrad route" do
      let(:trainee) { create(:trainee, :early_years_postgrad) }

      it { is_expected.to be_truthy }
    end

    context "when the bursary amount is calculated on the selected route and subject" do
      before { allow(CalculateBursary).to receive(:for_route_and_subject).and_return(1000) }

      it { is_expected.to be_truthy }
    end
  end

  describe "#with_name_trainee_id_or_trn_like" do
    let(:other_trainee) { create(:trainee) }
    let(:matching_trainee) do
      create(:trainee, middle_names: "Firstmiddle Secondmiddle", trn: "123")
    end

    subject { described_class.with_name_trainee_id_or_trn_like(search_term) }

    shared_examples_for "a working search" do
      it "returns the matching trainee" do
        expect(subject).to contain_exactly(matching_trainee)
      end
    end

    context "with an exactly matching first name" do
      let(:search_term) { matching_trainee.first_names }

      it_behaves_like "a working search"
    end

    context "with exactly matching (second) middle name" do
      let(:search_term) { "Secondmiddle" }

      it_behaves_like "a working search"
    end

    context "with exactly matching last name" do
      let(:search_term) { matching_trainee.last_name }

      it_behaves_like "a working search"
    end

    context "with a matching trainee id" do
      let(:search_term) { matching_trainee.trn }

      it_behaves_like "a working search"
    end

    context "with extra spaces in the search term" do
      let(:search_term) { "Firstmiddle  Secondmiddle" }

      it_behaves_like "a working search"
    end

    context "with incorrect case" do
      let(:search_term) { "firstMiddle" }

      it_behaves_like "a working search"
    end

    context "with partial search term" do
      let(:search_term) { "First" }

      it_behaves_like "a working search"
    end
  end

  describe "#ordered_by_date" do
    let(:trainee_one) { create(:trainee, updated_at: 1.day.ago) }
    let(:trainee_two) { create(:trainee, updated_at: 1.hour.ago) }

    it "orders the trainess by updated_at in descending order" do
      expect(Trainee.ordered_by_date).to eq([trainee_two, trainee_one])
    end
  end

  describe "#ordered_by_last_name" do
    let(:trainee_one) { create(:trainee, last_name: "Smith") }
    let(:trainee_two) { create(:trainee, last_name: "Jones") }

    it "orders the trainess by last name in ascending order" do
      expect(Trainee.ordered_by_last_name).to eq([trainee_two, trainee_one])
    end
  end

  describe "#with_subject" do
    let!(:trainee_with_subject) { create(:trainee, course_subject_one: Dttp::CodeSets::CourseSubjects::BIOLOGY) }
    let!(:trainee_without_subject) { create(:trainee, course_subject_one: Dttp::CodeSets::CourseSubjects::MATHEMATICS) }

    subject { described_class.with_subject(Dttp::CodeSets::CourseSubjects::BIOLOGY) }

    it { is_expected.to eq([trainee_with_subject]) }

    context "with lowercase subject name" do
      let!(:trainee_with_subject) { create(:trainee, course_subject_one: "biology") }

      it { is_expected.to eq([trainee_with_subject]) }
    end

    context "with multiple subjects" do
      let!(:trainee_with_subject_two) do
        create(:trainee,
               course_subject_one: Dttp::CodeSets::CourseSubjects::MATHEMATICS,
               course_subject_two: Dttp::CodeSets::CourseSubjects::BIOLOGY)
      end

      let!(:trainee_with_subject_three) do
        create(:trainee,
               course_subject_one: Dttp::CodeSets::CourseSubjects::MATHEMATICS,
               course_subject_two: Dttp::CodeSets::CourseSubjects::SOCIAL_SCIENCES,
               course_subject_three: Dttp::CodeSets::CourseSubjects::BIOLOGY)
      end

      it { is_expected.to match_array([trainee_with_subject, trainee_with_subject_two, trainee_with_subject_three]) }
    end
  end

  describe "#ordered_by_drafts" do
    let(:deferred_trainee_a) { create(:trainee, :deferred, id: 1) }
    let(:submitted_for_trn_trainee_b) { create(:trainee, :submitted_for_trn, id: 2) }
    let(:draft_trainee_c) { create(:trainee, :draft, id: 3) }
    let(:draft_trainee_d) { create(:trainee, :draft, id: 4) }

    it "orders the trainees by drafts first, then any other state" do
      expected_order = [
        draft_trainee_c,
        draft_trainee_d,
        deferred_trainee_a,
        submitted_for_trn_trainee_b,
      ]
      expect(Trainee.ordered_by_drafts.order(:id)).to eq(expected_order)
    end
  end

  describe "auditing" do
    it { is_expected.to be_audited.associated_with(:provider) }
  end

  describe "#set_early_years_course_subject" do
    let(:trainee) { build(:trainee, :early_years_undergrad) }

    it "sets course_subject_one to early years teaching and age range to 0-5" do
      trainee.set_early_years_course_details
      expect(trainee.course_subject_one).to eq(Dttp::CodeSets::CourseSubjects::EARLY_YEARS_TEACHING)
      expect(trainee.course_age_range).to eq(AgeRange::ZERO_TO_FIVE)
    end
  end
end

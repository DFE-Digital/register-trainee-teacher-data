# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromApply do
    let(:apply_application) { create(:apply_application) }

    let(:candidate_info) { ApiStubs::ApplyApi.candidate_info.as_json }
    let(:contact_details) { ApiStubs::ApplyApi.contact_details.as_json }
    let(:non_uk_contact_details) { ApiStubs::ApplyApi.non_uk_contact_details.as_json }
    let(:course_info) { ApiStubs::ApplyApi.course.as_json }
    let(:trainee) { create_trainee_from_apply }
    let(:subject_names) { [] }

    let!(:course) do
      create(
        :course_with_subjects,
        code: course_info["course_code"],
        accredited_body_code: apply_application.provider.code,
        route: :school_direct_tuition_fee,
        subject_names: subject_names,
      )
    end

    let(:trainee_attributes) do
      {
        trainee_id: nil,
        first_names: candidate_info["first_name"],
        last_name: candidate_info["last_name"],
        date_of_birth: candidate_info["date_of_birth"].to_date,
        gender: candidate_info["gender"],
        ethnic_group: "not_provided_ethnic_group",
        ethnic_background: candidate_info["ethnic_background"],
        diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
        email: contact_details["email"],
        training_route: course.route,
        course_code: course.code,
      }
    end

    let(:uk_address_attributes) do
      {
        address_line_one: contact_details["address_line1"],
        address_line_two: contact_details["address_line2"],
        town_city: contact_details["address_line3"],
        postcode: contact_details["postcode"],
        locale_code: "uk",
      }
    end

    let(:non_uk_address_attributes) do
      {
        international_address: non_uk_contact_details["address_line1"],
        locale_code: "non_uk",
      }
    end

    subject(:create_trainee_from_apply) { described_class.call(application: apply_application) }

    it "creates a draft trainee" do
      expect {
        create_trainee_from_apply
      }.to change(Trainee.draft, :count).by(1)
    end

    it { is_expected.to have_attributes(trainee_attributes) }

    it "associates the created trainee against the apply_application and provider" do
      expect(trainee.apply_application).to eq(apply_application)
      expect(trainee.provider).to eq(apply_application.provider)
    end

    context "with a uk address" do
      it { is_expected.to have_attributes(uk_address_attributes) }
    end

    context "with a non-uk address" do
      let(:apply_application) { create(:apply_application, application: ApiStubs::ApplyApi.non_uk_application.to_json) }

      it { is_expected.to have_attributes(non_uk_address_attributes) }
    end

    context "when disabilities exist" do
      before do
        Disability.create!(Diversities::SEED_DISABILITIES.map(&:to_h))
      end

      it "adds the trianee's disabilities" do
        expect(trainee.disabilities.map(&:name)).to match_array(["Blind", "Long-standing illness"])
      end
    end

    context "when nationalities exist" do
      before do
        Nationality.create!(Dttp::CodeSets::Nationalities::MAPPING.keys.map { |key| { name: key } })
      end

      it "adds the trainee's nationalities" do
        expect(trainee.nationalities.map(&:name)).to match_array(%w[british tristanian])
      end
    end
  end
end

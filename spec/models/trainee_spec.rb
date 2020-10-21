require "rails_helper"

describe Trainee do
  context "fields" do
    subject { build(:trainee) }

    it { is_expected.to define_enum_for(:record_type).with_values(assessment_only: 0) }
    it { is_expected.to define_enum_for(:locale_code).with_values(uk: 0, non_uk: 1) }
    it { is_expected.to define_enum_for(:gender).with_values(male: 0, female: 1, other: 2) }
    it { is_expected.to define_enum_for(:diversity_disclosure).with_values(yes: 0, no: 1) }

    it do
      is_expected.to define_enum_for(:ethnic_group).with_values(
        asian: 0,
        black: 1,
        mixed: 2,
        white: 3,
        other_ethnic_group: 4,
        no_ethnicity_provided: 5,
      )
    end
  end

  context "associations" do
    it { is_expected.to have_many(:degrees).dependent(:destroy) }
    it { is_expected.to have_many(:nationalisations).dependent(:destroy).inverse_of(:trainee) }
    it { is_expected.to have_many(:nationalities).through(:nationalisations) }
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
        context "when record type is present" do
          subject { build(:trainee, record_type: "assessment_only") }

          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context "when record type is not present" do
          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors.keys).to include(:record_type)
          end
        end

        context "when trainee id is over 100 characters" do
          subject { build(:trainee, trainee_id: SecureRandom.alphanumeric(101)) }

          it "is not valid" do
            expect(subject).not_to be_valid
            expect(subject.errors.keys).to include(:trainee_id)
          end
        end

        context "when trainee id is under 100 characters" do
          subject { build(:trainee, trainee_id: SecureRandom.alphanumeric(99)) }

          it "is valid" do
            expect(subject).to be_valid
          end
        end
      end
    end
  end
end

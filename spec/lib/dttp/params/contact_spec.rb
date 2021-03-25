# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    describe Contact do
      let(:time_now_in_zone) { Time.zone.now }
      let(:provider) { build(:provider, dttp_id: provider_dttp_id) }
      let(:provider_dttp_id) { SecureRandom.uuid }
      let(:trainee) { create(:trainee, :completed, gender: "female", provider: provider) }
      let(:trainee_creator_dttp_id) { SecureRandom.uuid }

      subject { described_class.new(trainee, trainee_creator_dttp_id).params }

      before do
        allow(Time).to receive(:now).and_return(time_now_in_zone)
      end

      describe "#params" do
        let(:prospective_trainee_state) do
          Dttp::CodeSets::Statuses::MAPPING[DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED][:entity_id]
        end

        it "returns a hash with all the DTTP basic contact fields and type, state and trn date" do
          expect(subject).to include({
            "firstname" => trainee.first_names,
            "lastname" => trainee.last_name,
            "address1_line1" => trainee.address_line_one,
            "address1_line2" => trainee.address_line_two,
            "address1_line3" => trainee.town_city,
            "address1_postalcode" => trainee.postcode,
            "birthdate" => trainee.date_of_birth.to_s,
            "emailaddress1" => trainee.email,
            "gendercode" => Dttp::Params::Contact::GENDER_CODES[:female],
            "dfe_traineeid" => trainee.trainee_id,
            "dfe_ContactTypeId@odata.bind" => "/dfe_contacttypes(faba11c7-07d9-e711-80e1-005056ac45bb)",
            "dfe_CreatedById@odata.bind" => "/contacts(#{trainee_creator_dttp_id})",
            "parentcustomerid_account@odata.bind" => "/accounts(#{provider_dttp_id})",
            "dfe_trnassessmentdate" => time_now_in_zone.in_time_zone.iso8601,
          })
        end

        context "trainee_creator_dttp_id not passed" do
          subject { described_class.new(trainee, trainee_creator_dttp_id).params }

          it "returns a hash with only the basic contact fields" do
            expect(subject).to include({
              "dfe_ContactTypeId@odata.bind" => "/dfe_contacttypes(faba11c7-07d9-e711-80e1-005056ac45bb)",
              "firstname" => trainee.first_names,
              "lastname" => trainee.last_name,
              "address1_line1" => trainee.address_line_one,
              "address1_line2" => trainee.address_line_two,
              "address1_line3" => trainee.town_city,
              "address1_postalcode" => trainee.postcode,
              "birthdate" => trainee.date_of_birth.to_s,
              "emailaddress1" => trainee.email,
              "gendercode" => Dttp::Params::Contact::GENDER_CODES[:female],
              "dfe_traineeid" => trainee.trainee_id,
              "parentcustomerid_account@odata.bind" => "/accounts(#{provider_dttp_id})",
            })
          end
        end

        context "trainee.traineeid is null" do
          let(:trainee) { create(:trainee, :completed, gender: "female", provider: provider, trainee_id: nil) }

          it "sets the dfe_traineeid to NOTPROVIDED" do
            expect(subject).to include(
              { "dfe_traineeid" => "NOTPROVIDED" },
            )
          end
        end

        context "diversity information" do
          let(:dttp_ethnicity_entity_id) { Dttp::CodeSets::Ethnicities::MAPPING[ethnic_background][:entity_id] }
          let(:dttp_disability_entity_id) { Dttp::CodeSets::Disabilities::MAPPING[dttp_disability][:entity_id] }

          let(:disability_param) do
            { "dfe_DisibilityId@odata.bind" => "/dfe_disabilities(#{dttp_disability_entity_id})" }
          end

          let(:ethnicity_param) do
            { "dfe_EthnicityId@odata.bind" => "/dfe_ethnicities(#{dttp_ethnicity_entity_id})" }
          end

          context "undisclosed" do
            let(:trainee) { create(:trainee, :completed, :diversity_not_disclosed) }
            let(:ethnic_background) { Diversities::NOT_PROVIDED }
            let(:dttp_disability) { Diversities::NOT_PROVIDED }

            it "returns a hash with a foreign key matching DTTP's 'Not known' ethnicity entity" do
              expect(subject).to include(disability_param, ethnicity_param)
            end
          end

          context "disclosed" do
            context "ethnicity information" do
              let(:trainee) { create(:trainee, :completed, :diversity_disclosed, ethnic_background: ethnic_background) }

              context "ethnic background provided" do
                before do
                  trainee.ethnic_group = Diversities::ETHNIC_GROUP_ENUMS[:white]
                end

                let(:ethnic_background) { Diversities::IRISH }

                it "returns a hash with a foreign key of DTTP's 'Irish' ethnicity entity" do
                  expect(subject).to include(ethnicity_param)
                end
              end

              context "ethnic background not provided" do
                let(:ethnic_background) { Diversities::NOT_PROVIDED }

                it "returns a hash with a foreign of DTTP's 'Not known' ethnicity entity" do
                  expect(subject).to include(ethnicity_param)
                end
              end

              context "ethnic group not provided" do
                let(:dttp_ethnicity_entity_id) { Dttp::CodeSets::Ethnicities::MAPPING[Diversities::NOT_PROVIDED][:entity_id] }
                let(:ethnic_background) { nil }

                before do
                  trainee.ethnic_group = Diversities::ETHNIC_GROUP_ENUMS[:not_provided]
                end

                it "returns a hash with a foreign of DTTP's 'Not known' ethnicity entity" do
                  expect(subject).to include(ethnicity_param)
                end
              end
            end

            context "disability information" do
              let(:trainee) { create(:trainee, :completed, :diversity_disclosed, disability_disclosure: disability_disclosure) }

              context "disabled" do
                let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] }

                context "only one disability" do
                  let(:dttp_disability) { Diversities::BLIND }

                  before do
                    trainee.disabilities << create(:disability, name: dttp_disability)
                  end

                  it "returns a hash with a foreign key of DTTP's 'Blind' disability entity" do
                    expect(subject).to include(disability_param)
                  end
                end

                context "more than one disability" do
                  let(:dttp_disability) { Diversities::MULTIPLE_DISABILITIES }

                  before do
                    trainee.disabilities += build_list(:disability, 2)
                  end

                  it "returns a hash with a foreign key of DTTP's 'Multiple disabilities' entity" do
                    expect(subject).to include(disability_param)
                  end
                end
              end

              context "not disabled" do
                let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_disabled] }
                let(:dttp_disability) { Diversities::NO_KNOWN_DISABILITY }

                it "returns a hash with a foreign key of DTTP's 'No known disability' entity" do
                  expect(subject).to include(disability_param)
                end
              end

              context "not provided" do
                let(:disability_disclosure) { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] }
                let(:dttp_disability) { Diversities::NOT_PROVIDED }

                it "returns a hash with a foreign key of DTTP's 'Not known' entity" do
                  expect(subject).to include(disability_param)
                end
              end
            end
          end
        end

        context "nationality information" do
          let(:expected_nationality) { create(:nationality, trait_name) }
          let(:other_nationality) { create(:nationality, :other) }

          let(:trainee) { create(:trainee) }

          let(:nationality_param) do
            { "dfe_Nationality@odata.bind" => "/dfe_nations(#{dttp_nationality_entity_id})" }
          end

          let(:dttp_nationality_entity_id) { Dttp::CodeSets::Nationalities::MAPPING[expected_nationality.name][:entity_id] }

          before do
            trainee.nationalities << [expected_nationality, other_nationality, create(:nationality)]
          end

          context "when British is selected with other nationalities" do
            let(:trait_name) { CodeSets::Nationalities::BRITISH.to_sym }

            it "sets the British nationality id" do
              expect(subject).to include(nationality_param)
            end
          end

          context "when Irish is selected with other nationalities" do
            let(:trait_name) { CodeSets::Nationalities::IRISH.to_sym }

            it "sets the Irish nationality id" do
              expect(subject).to include(nationality_param)
            end
          end

          context "when British and Irish are not selected" do
            let(:expected_nationality) { create(:nationality, name: "chinese") }

            it "sets the first nationality id" do
              expect(subject).to include(nationality_param)
            end
          end
        end
      end
    end
  end
end

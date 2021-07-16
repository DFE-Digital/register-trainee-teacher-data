# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe ContactUpdate do
    describe "#call" do
      let(:trainee) do
        create(:trainee,
               :completed,
               dttp_id: contact_dttp_id,
               placement_assignment_dttp_id: placement_assignment_dttp_id)
      end

      let(:contact_dttp_id) { SecureRandom.uuid }
      let(:placement_assignment_dttp_id) { SecureRandom.uuid }
      let(:contact_path) { "/contacts(#{contact_dttp_id})" }
      let(:placement_path) { "/dfe_placementassignments(#{placement_assignment_dttp_id})" }

      let(:contact_payload) { Params::Contact.new(trainee).to_json }
      let(:placement_payload) { Params::PlacementAssignment.new(trainee).to_json }
      let(:contact_request_url) { "#{Settings.dttp.api_base_url}#{contact_path}" }
      let(:placement_request_url) { "#{Settings.dttp.api_base_url}#{placement_path}" }

      before do
        enable_features(:persist_to_dttp, "routes.school_direct_salaried", "routes.school_direct_tuition_fee", "routes.pg_teaching_apprenticeship", :show_funding, :send_funding_to_dttp)
        allow(AccessToken).to receive(:fetch).and_return("token")
        stub_request(:patch, contact_request_url).to_return(contact_response)
        stub_request(:patch, placement_request_url).to_return(placement_response)
        trainee.degrees << create(:degree)
      end

      subject { described_class.call(trainee: trainee) }

      context "when successful" do
        let(:contact_response) { { status: 204 } }
        let(:placement_response) { { status: 204 } }

        before do
          expect(Client).to receive(:patch).with(contact_path, body: contact_payload).and_call_original
          expect(Client).to receive(:patch).with(placement_path, body: placement_payload).and_call_original
        end

        it "sends a PATCH request to update contact and placement assignment entities" do
          allow(Dttp::CreateOrUpdateConsistencyCheckJob).to receive(:perform_later).and_return(true)
          subject
        end

        it "enqueues the CreateOrUpdateConsistencyJob" do
          expect {
            subject
          }.to have_enqueued_job(Dttp::CreateOrUpdateConsistencyCheckJob).with(trainee)
        end
      end

      it_behaves_like "an http error handler" do
        let(:contact_response) { http_response }
        let(:placement_response) { http_response }
      end
    end
  end
end

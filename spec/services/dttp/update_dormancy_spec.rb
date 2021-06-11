# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe UpdateDormancy do
    describe "#call" do
      let(:trainee) do
        create(:trainee, :trn_received, :with_dttp_dormancy)
      end

      let(:path) { "/dfe_dormantperiods(#{trainee.dormancy_dttp_id})" }
      let(:expected_params) { { test: "value" }.to_json }

      before do
        enable_features(:persist_to_dttp)
        allow(AccessToken).to receive(:fetch).and_return("token")
        allow(Client).to receive(:patch).and_return(dttp_response)
        allow(Params::Dormancy).to receive(:new).with(trainee: trainee)
          .and_return(double(to_json: expected_params))
      end

      context "success" do
        let(:dttp_response) { double(code: 204) }

        it "sends a PATCH request to set entity property 'dfe_dormantperiods'" do
          expect(Client).to receive(:patch).with(path, body: expected_params).and_return(dttp_response)
          described_class.call(trainee: trainee)
        end
      end

      context "error" do
        let(:status) { 405 }
        let(:body) { "error" }
        let(:headers) { { foo: "bar" } }
        let(:dttp_response) { double(code: status, body: body, headers: headers) }

        it "raises an error exception" do
          expect {
            described_class.call(trainee: trainee)
          }.to raise_error(Dttp::UpdateDormancy::Error, "status: #{status}, body: #{body}, headers: #{headers}")
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Trainees::ConfirmReinstatementsController do
  include ActiveJob::TestHelper

  let(:current_user) { create(:user) }
  let(:trainee) { create(:trainee, :deferred, trn: trn, provider: current_user.provider) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "#update" do
    context "with a trainee with a trn" do
      let(:trn) { "trn" }

      it "transitions the trainee back to trn_received" do
        expect {
          post :update, params: { trainee_id: trainee }
          trainee.reload
        }.to change {
          trainee.state
        } .from("deferred") .to("trn_received")
      end

      it "queues a background job to reinstate a trainee" do
        expect {
          post :update, params: { trainee_id: trainee }
        }.to have_enqueued_job(ReinstateJob).with(trainee.id)
      end
    end

    context "with a trainee with no trn" do
      let(:trn) { nil }

      it "transitions the trainee back to submitted_for_trn" do
        expect {
          post :update, params: { trainee_id: trainee }
          trainee.reload
        }.to change {
          trainee.state
        } .from("deferred") .to("submitted_for_trn")
      end

      it "queues a background job to reinstate a trainee" do
        expect {
          post :update, params: { trainee_id: trainee }
        }.to have_enqueued_job(ReinstateJob).with(trainee.id)
      end
    end
  end
end
# frozen_string_literal: true

require "spec_helper"

describe ProgressService do
  describe "#status" do
    let(:trainee_stub) { instance_double(Trainee, apply_application?: false) }

    let(:validator_stub) do
      double(
        trainee: trainee_stub,
        valid?: false,
        fields: { first_name: nil },
      )
    end

    let(:progress_value) { false }

    subject { described_class.new(validator: validator_stub, progress_value: progress_value) }

    context "when not in progress or completed" do
      it "returns a 'not started' status" do
        expect(subject.status).to eq(Progress::STATUSES[:not_started])
      end
    end

    context "when started" do
      before do
        validator_stub.fields[:first_name] = "jon"
      end

      context "not completed" do
        it "returns an 'in progress' status" do
          expect(subject.status).to eq(Progress::STATUSES[:in_progress])
        end
      end

      context "and in review" do
        let(:trainee_stub) { instance_double(Trainee, apply_application?: true) }

        before do
          allow(validator_stub).to receive(:valid?).and_return(true)
        end

        it "returns a 'review' status" do
          expect(subject.status).to eq(Progress::STATUSES[:review])
        end
      end

      context "and completed" do
        let(:progress_value) { true }

        before do
          allow(validator_stub).to receive(:valid?).and_return(true)
        end

        it "returns a 'completed' status" do
          expect(subject.status).to eq(Progress::STATUSES[:completed])
        end
      end
    end
  end
end

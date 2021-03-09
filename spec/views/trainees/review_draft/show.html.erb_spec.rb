# frozen_string_literal: true

require "rails_helper"

describe "trainees/review_draft/show.html.erb" do
  before do
    allow(FeatureService).to receive(:enabled?).with(:routes_provider_led).and_return(true)
    assign(:trainee, trainee)
    render
  end

  context "with an Assessment only trainee" do
    let(:trainee) { create(:trainee) }

    it "does not render the placement details component" do
      expect(rendered).to_not have_text("Placement details")
    end
  end

  context "with a Provider-led trainee" do
    let(:trainee) { create(:trainee, :provider_led) }

    it "renders the placement details component" do
      expect(rendered).to have_text("Placement details")
    end
  end
end

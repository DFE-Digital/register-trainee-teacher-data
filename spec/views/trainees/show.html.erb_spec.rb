# frozen_string_literal: true

require "rails_helper"

describe "trainees/show.html.erb", 'feature_routes.provider_led_postgrad': true do
  before do
    assign(:trainee, trainee)
    render
  end

  context "with an Assessment only trainee" do
    let(:trainee) { create(:trainee, :submitted_for_trn) }

    it "does not render the placement details component" do
      expect(rendered).to_not have_text("Placement details")
    end
  end

  context "with a Provider-led (postgrad) trainee" do
    let(:trainee) { create(:trainee, :submitted_for_trn, :provider_led_postgrad) }

    it "renders the placement details component" do
      expect(rendered).to have_text("Placement details")
    end
  end
end

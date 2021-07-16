# frozen_string_literal: true

require "rails_helper"

module ApplyTraineeData
  describe View do
    alias_method :component, :page

    before do
      form = ApplyTraineeDataForm.new(trainee)
      render_inline(View.new(trainee, form))
    end

    context "trainee with degrees" do
      let(:degree) { build(:degree, :uk_degree_with_details) }
      let(:trainee) { create(:trainee, nationalities: [build(:nationality)], degrees: [degree]) }

      it "has an expanded degrees section" do
        expect(component).to have_text(degree.subject)
      end
    end

    context "trainee without degrees" do
      let(:trainee) { create(:trainee, nationalities: [build(:nationality)], degrees: []) }

      it "has a collapsed degrees section" do
        expect(component).to have_text("Degree details not started")
      end
    end
  end
end

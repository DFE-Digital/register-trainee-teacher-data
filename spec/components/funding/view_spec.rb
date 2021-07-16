# frozen_string_literal: true

require "rails_helper"

module Funding
  describe View do
    before do
      render_inline(View.new(data_model: trainee))
    end

    context "with tieried bursary" do
      let(:trainee) { build(:trainee, :early_years_postgrad, applying_for_bursary: true, bursary_tier: BURSARY_TIERS.keys.first) }

      it "renders tiered bursary text" do
        expect(rendered_component).to have_text("Applied for Tier 1")
        expect(rendered_component).to have_text("£5,000 estimated bursary")
      end
    end

    context "assessment only route" do
      let(:state) { :draft }
      let(:trainee) { build(:trainee, state, training_initiative: training_initiative) }

      describe "on training initiative" do
        let(:training_initiative) { ROUTE_INITIATIVES.keys.first }

        it "renders" do
          expect(rendered_component).to have_text(t("activerecord.attributes.trainee.training_initiatives.#{training_initiative}"))
        end

        it "has correct change link" do
          expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/training-initiative/edit")
        end

        describe "has no bursary" do
          before do
            allow(CalculateBursary).to receive(:for_route_and_subject).with(
              trainee.training_route.to_sym,
              trainee.course_subject_one,
            ).and_return(nil)
            render_inline(View.new(data_model: trainee))
          end

          it "doesnt not render bursary row" do
            expect(rendered_component).not_to have_text("Bursary applied for")
          end

          context "and it non-draft" do
            let(:state) { :trn_received }

            it "renders bursary not available" do
              expect(rendered_component).to have_text("No bursaries available for this course")
            end
          end
        end

        describe "has bursary" do
          before do
            allow(CalculateBursary).to receive(:for_route_and_subject).with(
              trainee.training_route.to_sym,
              trainee.course_subject_one,
            ).and_return(24_000)
          end

          describe "bursary funded" do
            before do
              allow(trainee).to receive(:applying_for_bursary).and_return(true)
              render_inline(View.new(data_model: trainee))
            end

            it "renders" do
              expect(rendered_component).to have_text("Bursary applied for")
              expect(rendered_component).to have_text("£24,000 estimated bursary")
            end

            it "has correct change link" do
              expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit")
            end
          end

          describe "not bursary funded" do
            before do
              allow(trainee).to receive(:applying_for_bursary).and_return(false)
              render_inline(View.new(data_model: trainee))
            end

            it "renders" do
              expect(rendered_component).to have_text("Not bursary funded")
              expect(rendered_component).not_to have_text("£24,000 estimated bursary")
            end

            it "has correct change link" do
              expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/bursary/edit")
            end
          end
        end
      end

      describe "not on training initiative" do
        let(:training_initiative) { "no_initiative" }

        it "renders" do
          expect(rendered_component).to have_text(t("activerecord.attributes.trainee.training_initiatives.#{training_initiative}"))
        end

        it "has correct change links" do
          expect(rendered_component).to have_link(href: "/trainees/#{trainee.slug}/funding/training-initiative/edit")
        end
      end
    end
  end
end

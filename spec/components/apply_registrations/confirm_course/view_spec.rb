# frozen_string_literal: true

require "rails_helper"

module ApplyRegistrations
  module ConfirmCourse
    describe View do
      include SummaryHelper
      include CourseDetailsHelper

      let(:trainee) { build(:trainee) }

      context "default behaviour" do
        let(:course) { build(:course, duration_in_years: 2) }
        let(:specialisms) { ["Specialism 1"] }

        before do
          render_inline(View.new(trainee: trainee, course: course, specialisms: specialisms))
        end

        it "renders the course details" do
          expect(rendered_component).to have_text("#{course.name} (#{course.code})")
        end

        it "renders the level" do
          expect(rendered_component).to have_text(course.level.capitalize)
        end

        it "renders the age range" do
          expect(rendered_component).to have_text(age_range_for_summary_view(course.age_range))
        end

        it "renders the start date" do
          expect(rendered_component).to have_text(date_for_summary_view(course.start_date))
        end

        it "renders the duration" do
          expect(rendered_component).to have_text("#{course.duration_in_years} years")
        end
      end

      context "course subjects" do
        let(:course) { create(:course_with_subjects, subjects_count: subject_count) }

        before do
          render_inline(View.new(trainee: trainee, course: course, specialisms: specialisms))
        end

        context "with one subject" do
          let(:specialisms) { ["Specialism 1"] }
          let(:subject_count) { 1 }
          let(:expected_names) { subjects_for_summary_view(specialisms.first, nil, nil) }

          it "renders the first subject's name" do
            expect(rendered_component).to have_text(expected_names)
          end

          it "displays the correct subject summary label" do
            expect(rendered_component).to have_text(I18n.t("confirm_publish_course.view.subject"))
          end
        end

        context "with two subjects" do
          let(:specialisms) { ["Specialism 1", "Specialism 2"] }
          let(:subject_count) { 2 }
          let(:expected_names) { subjects_for_summary_view(specialisms.first, specialisms.second, nil) }

          it "renders the first and second subject's name" do
            expect(rendered_component).to have_text(expected_names)
          end

          it "displays the correct subject summary label" do
            expect(rendered_component).to have_text(I18n.t("confirm_publish_course.view.multiple_subjects"))
          end
        end

        context "with three subjects" do
          let(:specialisms) { ["Specialism 1", "Specialism 2", "Specialism 3"] }
          let(:subject_count) { 3 }
          let(:expected_names) { subjects_for_summary_view(*specialisms) }

          it "renders the first, second and third subject's name" do
            expect(rendered_component).to have_text(expected_names)
          end
        end
      end
    end
  end
end

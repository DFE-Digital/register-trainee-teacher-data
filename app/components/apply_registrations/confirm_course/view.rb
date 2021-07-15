# frozen_string_literal: true

module ApplyRegistrations
  module ConfirmCourse
    class View < GovukComponent::Base
      include SummaryHelper
      include CourseDetailsHelper

      attr_accessor :trainee, :course, :specialisms

      def initialize(trainee:, course:, specialisms:)
        @trainee = trainee
        @course = course
        @specialisms = specialisms
      end

      def heading
        t(".heading")
      end

      def summary_title
        t(".summary_title")
      end

      def rows
        [
          {
            key: summary_title,
            value: course_details,
            action: govuk_link_to(t(".change_course"), edit_trainee_publish_course_details_path(@trainee, context: :apply)),
          },
          { key: t(".route"), value: t("activerecord.attributes.trainee.training_routes.#{@trainee.training_route}") },
          { key: subject_key, value: subject_names },
          { key: t(".level"), value: level },
          { key: t(".age_range"), value: age_range },
          { key: t(".start_date"), value: start_date },
          { key: t(".duration"), value: duration },
        ]
      end

      def course_details
        "#{course.name} (#{course.code})"
      end

      def subject_names
        specialism1, specialism2, specialism3 = *specialisms
        subjects_for_summary_view(
          specialism1,
          specialism2,
          specialism3,
        )
      end

      def level
        course.level&.capitalize
      end

      def age_range
        age_range_for_summary_view(course.age_range)
      end

      def start_date
        date_for_summary_view(course.start_date)
      end

      def duration
        pluralize(course.duration_in_years, "year")
      end

    private

      def subject_key
        course.subjects.count > 1 ? t(".multiple_subjects") : t(".subject")
      end
    end
  end
end

# frozen_string_literal: true

module Trainees
  module Confirmation
    module ConfirmPublishCourse
      class View < GovukComponent::Base
        include SummaryHelper
        include CourseDetailsHelper

        attr_accessor :trainee, :course

        def initialize(trainee:, course:)
          @trainee = trainee
          @course = course
        end

        def heading
          t(".heading")
        end

        def heading_text
          t(".heading_text")
        end

        def summary_title
          t(".summary_title")
        end

        def rows
          [
            {
              key: t(".summary_title"),
              value: course_details,
              action: govuk_link_to(t(".change_course"), edit_trainee_publish_course_details_path(@trainee)),
            },
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
          subjects_for_summary_view(
            course.subject_one&.name,
            course.subject_two&.name,
            course.subject_three&.name,
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
end

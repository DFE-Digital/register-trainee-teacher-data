# frozen_string_literal: true

require "govuk/components"

module ApplyRegistrations
  module ConfirmCourse
    class ViewPreview < ViewComponent::Preview
      def default
        render(View.new(trainee: mock_trainee, course: build_course, specialisms: build_specialisms))
      end

      def with_two_subjects
        course = build_course
        course.subjects << Subject.new(name: "Subject 2")
        specialisms = build_specialisms
        specialisms << "Specialism 2"
        render(View.new(trainee: mock_trainee, course: course, specialisms: specialisms))
      end

      def with_three_subjects
        course = build_course
        course.subjects << Subject.new(name: "Subject 2")
        course.subjects << Subject.new(name: "Subject 3")
        specialisms = build_specialisms
        specialisms << "Specialism 2"
        specialisms << "Specialism 3"
        render(View.new(trainee: mock_trainee, course: course, specialisms: specialisms))
      end

    private

      def mock_trainee
        @mock_trainee ||= Trainee.new(
          id: 1,
          course_subject_one: "Primary",
          course_age_range: [3, 11],
          course_start_date: Date.new(2020, 0o1, 28),
          training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad],
        )
      end

      def build_course
        Course.new(
          id: 1,
          name: "Primary",
          code: "2CX",
          level: :primary,
          min_age: 7,
          max_age: 11,
          start_date: Time.zone.today,
          duration_in_years: 1,
          subjects: [Subject.new(name: "Subject 1")],
        )
      end

      def build_specialisms
        ["Specialism 1"]
      end
    end
  end
end

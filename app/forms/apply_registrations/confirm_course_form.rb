# frozen_string_literal: true

module ApplyRegistrations
  class ConfirmCourseForm
    include ActiveModel::Model
    include CourseFormHelpers

    FIELDS = %i[
      code
      mark_as_reviewed
    ].freeze

    attr_accessor(*FIELDS, :trainee, :specialisms, :params)

    delegate :id, :persisted?, to: :trainee

    def initialize(trainee, specialisms, params = {})
      @trainee = trainee
      @specialisms = specialisms
      assign_attributes({ mark_as_reviewed: trainee.progress.course_details }.merge(params))
    end

    def save
      update_trainee_attributes

      clear_bursary_information if course_subjects_changed?

      trainee.save!
    end

  private

    def update_trainee_attributes
      course_subject_one, course_subject_two, course_subject_three = *specialisms
      trainee.assign_attributes({
        training_route: course&.route,
        course_code: course.code,
        course_age_range: course.age_range,
        course_start_date: course.start_date,
        course_end_date: course.end_date,
        course_subject_one: course_subject_one,
        course_subject_two: course_subject_two,
        course_subject_three: course_subject_three,
      })
      trainee.progress.course_details = mark_as_reviewed
    end

    def course
      @course ||= trainee.available_courses.find_by(code: code)
    end
  end
end

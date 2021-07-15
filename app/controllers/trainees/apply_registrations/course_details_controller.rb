# frozen_string_literal: true

module Trainees
  module ApplyRegistrations
    class CourseDetailsController < ApplicationController
      before_action :authorize_trainee
      before_action :set_course
      helper_method :subject_specialism_path

      def show
        redirect_to trainee_apply_registrations_confirm_courses_path(trainee) if trainee.course_subject_one
      end

    private

      def set_course
        @course = trainee.available_courses.find_by(code: trainee.course_code)
      end

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def authorize_trainee
        authorize(trainee)
      end

      def subject_specialism_path
        if course_has_one_specialism?
          trainee_apply_registrations_confirm_courses_path(trainee)
        elsif specialism_type == :language
          edit_trainee_language_specialisms_path(trainee, course_code: trainee.course_code)
        else
          edit_trainee_subject_specialism_path(trainee, 1, course_code: trainee.course_code)
        end
      end

      def specialism_type
        @specialism_type ||= CalculateSubjectSpecialismType.call(subjects: course_subjects)
      end

      def course_has_one_specialism?
        CalculateSubjectSpecialisms.call(subjects: course_subjects).all? { |_, specialisms| specialisms.count < 2 }
      end

      def course_subjects
        @course_subjects ||= @course.subjects.pluck(:name)
      end
    end
  end
end

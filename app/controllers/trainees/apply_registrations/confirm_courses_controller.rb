# frozen_string_literal: true

module Trainees
  module ApplyRegistrations
    class ConfirmCoursesController < ApplicationController
      before_action :authorize_trainee
      before_action :set_course
      before_action :set_specialisms

      def show
        page_tracker.save_as_origin!
        @confirm_course_form = ::ApplyRegistrations::ConfirmCourseForm.new(trainee, @specialisms)
      end

      def update
        @confirm_course_form = ::ApplyRegistrations::ConfirmCourseForm.new(trainee, @specialisms, course_params)

        if @confirm_course_form.save
          clear_form_stash(trainee)
          redirect_to review_draft_trainee_path(trainee)
        else
          render :show
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def set_course
        @course = trainee.available_courses.find_by!(code: course_code)
      end

      def set_specialisms
        @specialisms = if trainee.course_subjects.any? && publish_course_details_form.code.nil?
                         trainee.course_subjects
                       else
                         selected_or_calculated_specialisms
                       end
      end

      def authorize_trainee
        authorize(trainee)
      end

      def course_params
        params.require(:apply_registrations_confirm_course_form).permit(*::ApplyRegistrations::ConfirmCourseForm::FIELDS)
      end

      def course_code
        publish_course_details_form.code || trainee.course_code
      end

      def publish_course_details_form
        @publish_course_details_form ||= PublishCourseDetailsForm.new(trainee)
      end

      def selected_or_calculated_specialisms
        case publish_course_details_form.specialism_form&.to_sym
        when :language
          LanguageSpecialismsForm.new(trainee).languages
        when :general
          SubjectSpecialismForm.new(trainee).specialisms
        else
          CalculateSubjectSpecialisms.call(subjects: @course.subjects.pluck(:name)).values.map(&:first).compact
        end
      end
    end
  end
end

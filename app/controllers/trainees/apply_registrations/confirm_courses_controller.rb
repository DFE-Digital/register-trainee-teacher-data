# frozen_string_literal: true

module Trainees
  module ApplyRegistrations
    class ConfirmCoursesController < ApplicationController
      before_action :authorize_trainee
      before_action :set_course

      def show
        page_tracker.save_as_origin!
        @confirm_course_form = ::ApplyRegistrations::ConfirmCourseForm.new(trainee, specialisms)
      end

      def update
        @confirm_course_form = ::ApplyRegistrations::ConfirmCourseForm.new(trainee, specialisms, course_params)

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
        @course = trainee.available_courses.find_by!(code: trainee.course_code)
      end

      def specialisms
        @specialisms ||= if user_chosen_specialisms&.any?
                           user_chosen_specialisms
                         elsif user_chosen_languages_specialisms&.any?
                           user_chosen_languages_specialisms
                         else
                           CalculateSubjectSpecialisms.call(subjects: @course.subjects.pluck(:name)).values.map(&:first).compact
                         end
      end

      def authorize_trainee
        authorize(trainee)
      end

      def user_chosen_languages_specialisms
        @user_chosen_languages_specialisms ||= LanguageSpecialismsForm.new(trainee).languages
      end

      def user_chosen_specialisms
        @user_chosen_specialisms ||= SubjectSpecialismForm.new(trainee).specialisms
      end

      def course_params
        params.require(:apply_registrations_confirm_course_form).permit(*::ApplyRegistrations::ConfirmCourseForm::FIELDS)
      end
    end
  end
end

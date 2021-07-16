# frozen_string_literal: true

module Trainees
  class LanguageSpecialismsController < ApplicationController
    before_action :authorize_trainee
    before_action :load_language_specialisms

    def edit
      @language_specialisms_form = LanguageSpecialismsForm.new(trainee)
    end

    def update
      @language_specialisms_form = LanguageSpecialismsForm.new(trainee, params: language_specialism_params, user: current_user)

      if @language_specialisms_form.stash
        redirect_to next_step_path
      else
        render :edit
      end
    end

  private

    def next_step_path
      if trainee.apply_application?
        trainee_apply_registrations_confirm_courses_path(trainee)
      else
        edit_trainee_confirm_publish_course_path(trainee_id: trainee.slug)
      end
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def course
      trainee.available_courses.find_by_code!(course_code)
    end

    def load_language_specialisms
      @language_specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name))[:course_subject_one]
    end

    def language_specialism_params
      params.fetch(:language_specialisms_form, {}).permit(language_specialisms: [])
    end

    def authorize_trainee
      authorize(trainee)
    end

    def publish_course_details_form
      @publish_course_details_form ||= PublishCourseDetailsForm.new(trainee)
    end

    def course_code
      publish_course_details_form.code || trainee.course_code
    end
  end
end

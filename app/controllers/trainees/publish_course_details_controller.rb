# frozen_string_literal: true

module Trainees
  class PublishCourseDetailsController < ApplicationController
    before_action :authorize_trainee

    def edit
      @courses = @trainee.available_courses
      @publish_course_details_form = PublishCourseDetailsForm.new(trainee)
    end

    def update
      @publish_course_details_form = PublishCourseDetailsForm.new(trainee, params: course_params, user: current_user)

      if course_chosen?
        trainee.update!(course_code: nil) if @publish_course_details_form.manual_entry_chosen?
        redirect_to next_step_path
      else
        @courses = @trainee.available_courses
        render :edit
      end
    end

  private

    def course_chosen?
      @publish_course_details_form.valid? && set_specialism_form_type && @publish_course_details_form.stash
    end

    def set_specialism_form_type
      type =
        if @publish_course_details_form.manual_entry_chosen? || course_has_one_specialism?
          nil
        elsif specialism_type == :language
          :language
        else
          :general
        end

      # If this is being changed from the confirm page, there may be something in these stashes that the
      # user won't get a chance to change - if there were more specialisms chosen for the previous option
      clear_form_stashes

      @publish_course_details_form.specialism_form = type

      true
    end

    def clear_form_stashes
      FormStore.set(@trainee.id, :subject_specialism, nil)
      FormStore.set(@trainee.id, :language_specialisms, nil)
    end

    def next_step_path
      if @publish_course_details_form.manual_entry_chosen?
        edit_trainee_course_details_path(@trainee)
      elsif course_has_one_specialism?
        course_confirmation_path
      elsif specialism_type == :language
        edit_trainee_language_specialisms_path(@trainee)
      else
        edit_trainee_subject_specialism_path(@trainee, 1)
      end
    end

    def course_has_one_specialism?
      CalculateSubjectSpecialisms.call(subjects: course_subjects).all? do |_, v|
        v.count < 2
      end
    end

    def specialism_type
      @specialism_type ||= CalculateSubjectSpecialismType.call(subjects: course_subjects)
    end

    def course_subjects
      @course_subjects ||= Course.find_by_code(@publish_course_details_form.code).subjects.map(&:name)
    end

    def course_params
      params.fetch(:publish_course_details_form, {}).permit(:code, :context)
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end

    def course_confirmation_path
      if @publish_course_details_form.for_apply_registration?
        trainee_apply_registrations_confirm_courses_path(trainee)
      else
        edit_trainee_confirm_publish_course_path(@trainee)
      end
    end
  end
end

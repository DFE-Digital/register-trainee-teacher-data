# frozen_string_literal: true

module Trainees
  class SubjectSpecialismsController < ApplicationController
    before_action :authorize_trainee
    helper_method :position

    def edit
      @subject = course.subjects[position - 1].name
      @specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.map(&:name))[:"course_subject_#{position_in_words}"]

      if @specialisms.count == 1
        SubjectSpecialismForm.new(trainee, position, params: { "specialism#{position}": @specialisms.first }).stash
        redirect_to next_step_path
        return
      end

      @subject_specialism_form = SubjectSpecialismForm.new(trainee, position)
    end

    def update
      @subject_specialism_form = SubjectSpecialismForm.new(trainee, position, params: specialism_params)

      if @subject_specialism_form.stash
        redirect_to next_step_path
      else
        @subject = course.subjects[position - 1].name
        @specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.map(&:name))[:"course_subject_#{position_in_words}"]
        render :edit
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def position
      params[:position].to_i
    end

    def position_in_words
      @_position_in_words ||= to_word(position)
    end

    def to_word(number)
      case number
      when 1
        "one"
      when 2
        "two"
      when 3
        "three"
      end
    end

    def authorize_trainee
      authorize(trainee)
    end

    def specialism_params
      return {} if params[:subject_specialism_form].blank?

      params
        .require(:subject_specialism_form)
        .permit(:"specialism#{position}", "specialism#{position}": [])
        .transform_values(&:first)
    end

    def course
      @course ||= trainee.available_courses.find_by_code!(course_code)
    end

    def next_step_path
      specialisms = CalculateSubjectSpecialisms.call(subjects: course.subjects.map(&:name))
      next_position = position + 1
      if specialisms[:"course_subject_#{to_word(next_position)}"].present?
        edit_trainee_subject_specialism_path(trainee, next_position)
      elsif trainee.apply_application?
        trainee_apply_registrations_confirm_courses_path(trainee)
      else
        edit_trainee_confirm_publish_course_path(trainee)
      end
    end

    def publish_course_details_form
      @publish_course_details_form ||= PublishCourseDetailsForm.new(trainee)
    end

    def course_code
      publish_course_details_form.code || trainee.course_code
    end
  end
end

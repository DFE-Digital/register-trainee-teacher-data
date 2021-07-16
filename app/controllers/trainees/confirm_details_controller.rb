# frozen_string_literal: true

module Trainees
  class ConfirmDetailsController < ApplicationController
    before_action :authorize_trainee

    helper_method :trainee_section_key
    helper_method :confirm_section_title

    def show
      page_tracker.save_as_origin!

      if trainee.draft?
        @confirm_detail_form = ConfirmDetailForm.new(mark_as_completed: trainee.progress.public_send(trainee_section_key))
        @checkbox_text = course_details_checkbox_text
      end

      @confirmation_component = component_klass.new(data_model: trainee.draft? ? trainee : form_klass.new(trainee))
    end

    def update
      form_klass.new(trainee).save! unless trainee.draft?

      toggle_trainee_progress_field if trainee.draft?

      flash[:success] = "Trainee #{flash_message_title} updated"

      redirect_to page_tracker.last_origin_page_path || trainee_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def component_klass
      "::#{trainee_section_key.underscore.camelcase}::View".constantize
    end

    def form_klass
      case trainee_section_key
      when "schools"
        Schools::FormValidator
      else
        "#{trainee_section_key.underscore.camelcase}Form".constantize
      end
    end

    # Returns the route that the confirm path is nested under for each confirm path
    # eg /trainees/HxA35kmiNdtwNGnWYjr6FbJZ/funding/confirm returns 'funding'
    def trainee_section_key
      @trainee_section_key ||= request.path.split("/")[-2]&.underscore
    end

    def confirm_section_title
      @confirm_section_title ||= {
        training_details: "start date and ID",
        degrees: "degree details",
        funding: "funding details",
      }[trainee_section_key.to_sym] || trainee_section_key.gsub(/_/, " ").gsub(/id/, "ID")
    end

    def flash_message_title
      I18n.t(
        "components.confirmation.flash.#{trainee_section_key}",
        default: confirm_section_title.pluralize,
      )
    end

    def course_details_checkbox_text
      trainee.apply_application? && trainee_section_key == "course_details" ? t("mark_as_completed", action: "reviewed") : t("mark_as_completed", action: "completed")
    end

    def toggle_trainee_progress_field
      trainee.progress.public_send("#{trainee_section_key}=", mark_as_completed_params)
      trainee.save!
    end

    def mark_as_completed_params
      mark_as_completed_attributes = params.require(:confirm_detail_form).permit(:mark_as_completed)[:mark_as_completed]

      ActiveModel::Type::Boolean.new.cast(mark_as_completed_attributes)
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end

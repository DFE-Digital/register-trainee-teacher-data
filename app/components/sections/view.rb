# frozen_string_literal: true

module Sections
  class View < ViewComponent::Base
    attr_accessor :trainee, :section, :form

    def initialize(trainee:, section:, form:)
      @trainee = trainee
      @section = section
      @form = form
    end

    def component
      if display_type == :expanded
        confirmation_view_args = { data_model: form_klass.new(trainee) }

        if section == :degrees
          confirmation_view_args.merge!(show_add_another_degree_button: false, show_delete_button: true)
        end

        confirmation_view.new(**confirmation_view_args)
      else
        CollapsedSection::View.new(title: title, link_text: link_text, url: url, error: error)
      end
    end

  private

    def form_klass
      case section
      when :schools
        Schools::FormValidator
      when :funding
        Funding::FormValidator
      else
        "#{section.to_s.camelcase}Form".constantize
      end
    end

    def confirmation_view
      {
        personal_details: PersonalDetails::View,
        contact_details: ContactDetails::View,
        diversity: Diversity::View,
        degrees: Degrees::View,
        course_details: CourseDetails::View,
        training_details: TrainingDetails::View,
        schools: Schools::View,
        funding: Funding::View,
      }[section]
    end

    def path
      {
        personal_details: {
          not_started: "edit_trainee_personal_details_path",
          in_progress: "trainee_personal_details_confirm_path",
        },
        contact_details: {
          not_started: "edit_trainee_contact_details_path",
          in_progress: "trainee_contact_details_confirm_path",
        },
        diversity: {
          not_started: "edit_trainee_diversity_disclosure_path",
          in_progress: "trainee_diversity_confirm_path",
        },
        degrees: {
          not_provided: "trainee_degrees_new_type_path",
          not_started: "trainee_degrees_new_type_path",
          in_progress: "trainee_degrees_confirm_path",
        },
        course_details: {
          not_started: "edit_trainee_course_details_path",
          in_progress: "trainee_course_details_confirm_path",
        },
        training_details: {
          not_started: "edit_trainee_training_details_path",
          in_progress: "trainee_training_details_confirm_path",
        },
        schools: {
          not_started: "edit_trainee_lead_schools_path",
          in_progress: "trainee_schools_confirm_path",
        },
        funding: {
          not_started: "edit_trainee_funding_training_initiative_path",
          in_progress: "trainee_funding_confirm_path",
        },
      }[section][progress_status]
    end

    def error
      @error ||= form.errors.present?
    end

    def progress_status
      @progress_status ||= form.progress_status(section)
    end

    def display_type
      @display_type ||= form.display_type(section)
    end

    def title
      "#{section_title} #{section_status}"
    end

    def section_title
      I18n.t("components.sections.titles.#{section}")
    end

    def section_status
      I18n.t("components.sections.statuses.#{progress_status}")
    end

    def url
      Rails.application.routes.url_helpers.public_send(path, trainee)
    end

    def link_text
      link_text = I18n.t("components.sections.link_texts.#{progress_status}")
      "#{link_text}<span class=\"govuk-visually-hidden\"> #{section_title.downcase}</span>".html_safe
    end
  end
end

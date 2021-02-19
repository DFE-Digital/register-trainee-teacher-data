# frozen_string_literal: true

module Trainees
  module Sections
    class View < ViewComponent::Base
      attr_accessor :trainee, :section, :trn_submission

      def initialize(trainee:, section:, trn_submission:)
        @trainee = trainee
        @section = section
        @trn_submission = trn_submission
      end

      def component
        if status == :completed
          confirmation_view_args = { trainee: trainee }

          confirmation_view_args.merge!({ show_add_another_degree_button: false, show_delete_button: true }) if section == :degrees
          confirmation_view.new(**confirmation_view_args)
        else
          IncompleteSection::View.new(title: title, link_text: link_text, url: url, error: error)
        end
      end

    private

      def confirmation_view
        {
          personal_details: Trainees::Confirmation::PersonalDetails::View,
          contact_details: Trainees::Confirmation::ContactDetails::View,
          diversity: Trainees::Confirmation::Diversity::View,
          degrees: Trainees::Confirmation::Degrees::View,
          programme_details: Trainees::Confirmation::ProgrammeDetails::View,
          training_details: Trainees::Confirmation::TrainingDetails::View,
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
            not_started: "trainee_degrees_new_type_path",
            in_progress: "trainee_degrees_confirm_path",
          },
          programme_details: {
            not_started: "edit_trainee_programme_details_path",
            in_progress: "trainee_programme_details_confirm_path",
          },
          training_details: {
            not_started: "edit_trainee_training_details_path",
            in_progress: "trainee_training_details_confirm_path",
          },
        }[section][status]
      end

      def error
        @error ||= trn_submission.errors.present?
      end

      def status
        @status ||= trn_submission.section_status(section)
      end

      def title
        "#{section_title} #{section_status}"
      end

      def section_title
        I18n.t("components.sections.titles.#{section}")
      end

      def section_status
        I18n.t("components.sections.statuses.#{status}")
      end

      def url
        Rails.application.routes.url_helpers.public_send(path, trainee)
      end

      def link_text
        link_text = I18n.t("components.sections.link_texts.#{status}")
        "#{link_text}<span class=\"govuk-visually-hidden\"> #{section_title.downcase}</span>".html_safe
      end
    end
  end
end

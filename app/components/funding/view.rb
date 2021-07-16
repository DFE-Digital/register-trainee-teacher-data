# frozen_string_literal: true

module Funding
  class View < GovukComponent::Base
    include SanitizeHelper
    include FundingHelper

    attr_accessor :data_model

    def initialize(data_model:)
      @data_model = data_model
    end

    def trainee
      data_model.is_a?(Trainee) ? data_model : data_model.trainee
    end

    def title
      t(".title")
    end

    def rows
      rows = [
        {
          key: t(".training_initiative"),
          value: training_initiative,
          action: action_link("training initiative", edit_trainee_funding_training_initiative_path(trainee)),
        },
      ]

      if show_bursary_funding?
        rows << {
          key: t(".bursary_funding"),
          value: bursary_funding,
          action: (action_link("bursary funding", edit_trainee_funding_bursary_path(trainee)) if trainee.can_apply_for_bursary?),
        }
      end

      rows
    end

  private

    def course_subject_one
      trainee.course_subject_one
    end

    def show_bursary_funding?
      !trainee.draft? || trainee.can_apply_for_bursary?
    end

    def bursary_amount
      @bursary_amount ||= if trainee.bursary_tier.present?
                            CalculateBursary.for_tier(trainee.bursary_tier)
                          else
                            trainee.bursary_amount
                          end
    end

    def training_initiative
      if trainee.training_initiative.nil?
        t("components.confirmation.not_provided")
      else
        t("activerecord.attributes.trainee.training_initiatives.#{trainee.training_initiative}")
      end
    end

    def bursary_funding
      if trainee.applying_for_bursary.nil?
        return trainee.draft? ? t("components.confirmation.not_provided") : t(".no_bursary_available")
      end

      return "#{t(".tiered_bursary_applied_for.#{trainee.bursary_tier}")}#{bursary_funding_hint}".html_safe if trainee.bursary_tier.present?

      return "#{t('.bursary_applied_for')}#{bursary_funding_hint}".html_safe if trainee.applying_for_bursary

      t(".no_bursary_applied_for")
    end

    def bursary_funding_hint
      "<br>#{tag.span("#{format_currency(bursary_amount)} estimated bursary", class: 'govuk-hint')}"
    end

    def action_link(text, path)
      govuk_link_to("#{t(:change)}<span class='govuk-visually-hidden'> #{text}</span>".html_safe, path)
    end
  end
end

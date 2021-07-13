# frozen_string_literal: true

module PageObjects
  module Trainees
    class New < PageObjects::Base
      set_url "/trainees/new"

      element :page_heading, ".govuk-heading-xl"

      element :assessment_only, "#trainee-training-route-assessment-only-field"
      element :provider_led_postgrad, "#trainee-training-route-provider-led-postgrad-field"
      element :early_years_undergrad, "#trainee-training-route-early-years-undergrad-field"

      element :early_years_assessment_only, "#trainee-training-route-early-years-assessment-only-field"
      element :early_years_salaried, "#trainee-training-route-early-years-graduate-placement-based-field"
      element :early_years_postgrad, "#trainee-training-route-early-years-postgrad-field"
      element :school_direct_salaried, "#trainee-training-route-school-direct-salaried-field"
      element :school_direct_tuition_fee, "#trainee-training-route-school-direct-tuition-fee-field"
      element :pg_teaching_apprenticeship, "#trainee-training-route-pg-teaching-apprenticeship-field"

      element :other, "#trainee-training-route-other-field"

      element :continue_button, 'button.govuk-button[type="submit"]'
    end
  end
end

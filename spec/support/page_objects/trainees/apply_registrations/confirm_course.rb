# frozen_string_literal: true

module PageObjects
  module Trainees
    module ApplyRegistrations
      class SummaryListRows < SitePrism::Section
        element :key, ".govuk-summary-list__key"
        element :value, ".govuk-summary-list__value"
      end

      class ConfirmCourse < PageObjects::Base
        set_url "/trainees/{id}/apply-registrations/confirm-course"

        element :select_specialisms_button, ".govuk-button"

        sections :summary_list_rows, SummaryListRows, ".govuk-summary-list__row"

        def subject_description
          subject_row = summary_list_rows.find { |row| row.key.text =~ /Subject/ }
          subject_row.value.text
        end
      end
    end
  end
end

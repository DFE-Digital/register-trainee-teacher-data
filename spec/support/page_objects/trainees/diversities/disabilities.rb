# frozen_string_literal: true

module PageObjects
  module Trainees
    module Diversities
      class Disabilities < PageObjects::Base
        set_url "/trainees/{id}/diversity/disabilities/edit"

        element :disability, ".govuk-checkboxes.disability"
        element :submit_button, "button[type='submit']"
      end
    end
  end
end

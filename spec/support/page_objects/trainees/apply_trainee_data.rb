# frozen_string_literal: true

module PageObjects
  module Trainees
    class ApplyTraineeData < PageObjects::Base
      set_url "/trainees/{id}/apply-registrations/trainee-data/edit"

      element :full_name_change_link, ".full-name a"
      element :i_have_reviewed_checkbox, "#apply-registrations-trainee-data-form-mark-as-reviewed-1-field"
      element :continue, "button[type='submit']", text: "Continue"
    end
  end
end

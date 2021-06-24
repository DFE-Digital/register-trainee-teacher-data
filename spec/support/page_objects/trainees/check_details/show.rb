# frozen_string_literal: true

module PageObjects
  module Trainees
    module CheckDetails
      class Show < PageObjects::Base
        set_url "/trainees/{id}/check-details"

        element :back_to_draft_record, "#back-to-draft-record"
        element :return_to_draft_later, "#return-to-draft-later"
        element :submit_button, "button[type='submit']", text: "Submit record and request TRN"
      end
    end
  end
end

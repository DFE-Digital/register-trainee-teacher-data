# frozen_string_literal: true

module ApplyRegistrations
  module TraineeData
    class View < GovukComponent::Base
      include ApplicationHelper
      include TraineeHelper

      attr_reader :trainee, :form

      def initialize(trainee, form)
        @trainee = trainee
        @form = form
      end
    end
  end
end

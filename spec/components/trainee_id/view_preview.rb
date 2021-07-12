# frozen_string_literal: true

require "govuk/components"

module TraineeId
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(data_model: mock_trainee))
    end

    def with_no_data
      render(View.new(data_model: Trainee.new(id: 2)))
    end

  private

    def mock_trainee
      @mock_trainee ||= Trainee.new(
        id: 1,
        training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        trainee_id: "ABC-1234-XYZ",
      )
    end
  end
end

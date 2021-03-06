# frozen_string_literal: true

module Dttp
  class ChangeTraineeStatusJob < ApplicationJob
    queue_as :default
    retry_on Dttp::Client::HttpError

    def perform(trainee, status, entity_type)
      UpdateTraineeStatus.call(status: status, trainee: trainee, entity_type: entity_type)
    end
  end
end

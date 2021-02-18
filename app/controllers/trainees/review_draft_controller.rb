# frozen_string_literal: true

module Trainees
  class ReviewDraftController < ApplicationController
    before_action :ensure_trainee_is_draft!

    def show
      authorize trainee
      page_tracker.save_as_origin!
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:id])
    end
  end
end

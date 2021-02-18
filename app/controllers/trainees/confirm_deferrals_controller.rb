# frozen_string_literal: true

module Trainees
  class ConfirmDeferralsController < ApplicationController
    before_action :authorize_trainee

    def show
      page_tracker.save_as_origin!
    end

    def update
      trainee.defer!
      DeferJob.perform_later(trainee.id)

      flash[:success] = "Trainee deferred"
      redirect_to trainee_path(trainee)
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def authorize_trainee
      authorize(trainee)
    end
  end
end

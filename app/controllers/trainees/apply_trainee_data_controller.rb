# frozen_string_literal: true

module Trainees
  class ApplyTraineeDataController < ApplicationController
    before_action :authorize_trainee

    def edit
      page_tracker.save_as_origin!
      @form = ApplyTraineeDataForm.new(@trainee)
    end

    def update
      if params[:apply_trainee_data_form][:mark_as_reviewed] == "1"
        @form = ApplyTraineeDataForm.new(@trainee)
        if @form.save
          redirect_to trainee_path(trainee)
        else
          render :edit
        end
      end
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

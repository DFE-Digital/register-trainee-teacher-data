# frozen_string_literal: true

module Trainees
  module ApplyRegistrations
    class TraineeDataController < ApplicationController
      before_action :authorize_trainee

      def edit
        page_tracker.save_as_origin!
        @form = ApplyRegistrations::TraineeDataForm.new(trainee: @trainee)
      end

      def update
        if params[:apply_trainee_data_form][:mark_as_reviewed] == "1"
          @form = ApplyRegistrations::TraineeDataForm.new(trainee: @trainee)
          unless @form.save
            render :edit
          end
        end
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
end

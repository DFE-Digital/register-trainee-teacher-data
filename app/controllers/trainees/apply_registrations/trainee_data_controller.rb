# frozen_string_literal: true

module Trainees
  module ApplyRegistrations
    class TraineeDataController < ApplicationController
      before_action :authorize_trainee

      def edit
        page_tracker.save_as_origin!
        @trainee_data_form = ::ApplyRegistrations::TraineeDataForm.new(trainee: @trainee)
      end

      def update
        if params[:apply_registrations_trainee_data_form][:mark_as_reviewed] == "1"
          @trainee_data_form = ::ApplyRegistrations::TraineeDataForm.new(trainee: @trainee)
          render :edit unless @trainee_data_form.save
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

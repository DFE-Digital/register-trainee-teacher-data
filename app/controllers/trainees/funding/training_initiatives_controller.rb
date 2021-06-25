# frozen_string_literal: true

module Trainees
  module Funding
    class TrainingInitiativesController < ApplicationController
      before_action :authorize_trainee

      def edit
        @training_initiatives_form = ::Funding::TrainingInitiativesForm.new(trainee)
      end

      def update
        @training_initiatives_form = ::Funding::TrainingInitiativesForm.new(trainee, params: trainee_params, user: current_user)

        save_strategy = trainee.draft? ? :save! : :stash

        if @training_initiatives_form.public_send(save_strategy)
          redirect_to review_draft_trainee_path(trainee)
        else
          render :edit
        end
      end

    private

      def trainee
        @trainee ||= Trainee.from_param(params[:trainee_id])
      end

      def trainee_params
        return { training_initiative: nil } if params[:funding_training_initiatives_form].blank?

        params.require(:funding_training_initiatives_form).permit(*::Funding::TrainingInitiativesForm::FIELDS)
      end

      def authorize_trainee
        authorize(trainee)
      end
    end
  end
end
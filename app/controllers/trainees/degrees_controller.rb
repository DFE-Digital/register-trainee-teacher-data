# frozen_string_literal: true

module Trainees
  class DegreesController < ApplicationController
    before_action :authorize_trainee
    before_action :set_degrees_form

    def new
      @degree_form = @degrees_form.build_degree(locale_code: params[:locale_code])
    end

    def create
      @degree_form = @degrees_form.build_degree(degree_params, autocomplete_params)

      if @degree_form.save_or_stash
        trainee.apply_application? ? (redirect_to edit_trainee_apply_trainee_data_path(trainee)) : (redirect_to trainee_degrees_confirm_path(trainee))
      else
        render :new
      end
    end

    def edit
      @degree_form = @degrees_form.find_degree_from_param(params[:id])
    end

    def update
      @degree_form = @degrees_form.find_degree_from_param(params[:id])
      @degree_form.attributes = degree_params
      @degree_form.assign_attributes(autocomplete_params)

      if @degree_form.save_or_stash
        redirect_to relevant_redirect_path
      else
        render :edit
      end
    end

    def destroy
      @degree_form = @degrees_form.find_degree_from_param(params[:id])

      @degree_form.destroy!

      flash[:success] = "Trainee degree deleted"

      redirect_to page_tracker.last_origin_page_path
    end

  private

    def degree_params
      params.require(:degree).permit(DegreeForm::FIELDS.excluding(:slug, *DegreeForm::AUTOCOMPLETE_FIELDS))
    end

    def autocomplete_params
      params.require(:degree).permit(DegreeForm::AUTOCOMPLETE_FIELDS)
    end

    def authorize_trainee
      authorize(trainee)
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def set_degrees_form
      @degrees_form = DegreesForm.new(trainee)
    end

    def relevant_redirect_path
      trainee.apply_application? ? page_tracker.last_origin_page_path : trainee_degrees_confirm_path(trainee)
    end
  end
end
